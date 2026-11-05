import random
import rpyc
import multiprocessing
import threading
import time
import sys

N = 100
PORT1 = 18812
PORT2 = 18813
HOST1 = "100.27.92.54"
HOST2 = "3.85.203.89"
POINTS = 100
EXPECTED_CLIENTS = 3


class ScoreService(rpyc.Service):
    def __init__(self) -> None:
        print("Server: iniciando...")
        self.scoreboard = {
            "player1": 0,
            "player2": 0,
            "player3": 0,
        }  # scoreboard inicialmente vazia
        self.subscribers_callbacks = []  # callbacks que serão usadas para iniciar os clientes
        self.lock = threading.Lock()  # não afeta a condição de corrida do scoreboard. Usado em atributos de controle
        self.started = threading.Event()  # barreira para iniciar (usando callbacks) somente quando os clientes estiverem prontos
        self.endgame = (
            threading.Event()
        )  # barreira para clientes esperarem o placar final
        self.starter_thread = threading.Thread(
            target=self.start_signal
        )  # usa o self.started para chamar as callbacks
        self.starter_thread.start()
        self.ready_clients = 0  # clientes prontos para iniciar o jogo
        self.active_clients = 0  # clientes que ainda estão no jogo

    def exposed_get_score(self, player):
        return self.scoreboard[player]

    def exposed_set_score(self, player, new_score):
        if new_score > self.scoreboard[player]:
            self.scoreboard[player] = new_score

    def exposed_get_scoreboard_string(self):
        return str(self.scoreboard)

    def start_signal(self):
        # thread que observa self.started para notificar clientes que já podem começar
        # desnecessário se client_ready() iterar as callbacks???
        self.started.wait()
        print("Server: chamando callbacks de clientes", end="")
        with self.lock:
            callbacks = list(self.subscribers_callbacks)
        for func in callbacks:
            func()
            print(".", end="")
        print()

    def exposed_subscribe_callback(self, callback):
        # se compartilhar um objeto remoto threading.Event()?
        # Podemos sincronizar o inicio do jogo sem callbacks?
        print("Server: registrando callback")
        with self.lock:
            self.subscribers_callbacks.append(rpyc.async_(callback))

    def exposed_client_ready(self):
        # indica que o cliente está pronto, além de iniciar o jogo
        # quando a quantidade de clientes esperados estiver pronto
        with self.lock:
            self.ready_clients += 1
            if self.ready_clients == EXPECTED_CLIENTS:
                self.started.set()

    def on_connect(self, conn):
        print("Server: +1 cliente")
        with self.lock:
            self.active_clients += 1

    def exposed_wait_everyone(self):
        # bloqueia até todo mundo terminar
        with self.lock:
            self.active_clients -= 1
            if self.active_clients == 0:
                self.endgame.set()
        self.endgame.wait()

    def on_disconnect(self, conn):
        pass


class CoordinatorService(rpyc.Service):
    """'Coordenador para ser implementado na segunda parte"""

    def __init__(self) -> None:
        print("Coordenador: iniciando")
        self.condition = threading.Condition()
        self.occupied = False

    def exposed_request_critical_section(self):
        with self.condition:
            while self.occupied:
                self.condition.wait()
            self.occupied = True

    def exposed_release_critical_section(self):
        with self.condition:
            self.occupied = False
            self.condition.notify()

    def on_connect(self, conn):
        pass

    def on_disconnect(self, conn):
        pass


class Client:
    def __init__(self, name) -> None:
        self.name = name
        self.game_finished = threading.Event()
        print(f"{self.name}: Iniciando cliente")
        # para reprodutibilidade, cada player vai ter o score atualizado
        # N vezes por cada client
        self.players_updates = (
            ["player1" for _ in range(N)]
            + ["player2" for _ in range(N)]
            + ["player3" for _ in range(N)]
        )
        random.shuffle(self.players_updates)
        self.name = name

        self.srv_conn = rpyc.connect(HOST1, PORT1)
        self.cor_conn = rpyc.connect(HOST2, PORT2)

        print(f"{self.name}: Iniciando thread para atender servidor")
        self.bgsrv = rpyc.BgServingThread(
            self.srv_conn
        )  # thread para atender requisições do servidor

        self.srv_conn.root.subscribe_callback(self.on_game_started)

        self.srv_conn.root.client_ready()

    def get_score(self, player):
        return self.srv_conn.root.get_score(player)

    def update_score(self, player, new_score):
        self.srv_conn.root.set_score(player, new_score)

    def on_game_started(self):
        print(f"{self.name}: Callback foi chamada")
        self.loop()
        self.game_finished.set()

    def loop(self):
        print(f"{self.name}: Iniciando loop do jogo")
        while self.players_updates:
            player = self.players_updates.pop()

            # acesso a região crítica

            self.cor_conn.root.request_critical_section()

            score = self.get_score(player)
            score += POINTS
            self.update_score(player, score)

            self.cor_conn.root.release_critical_section()

            # fim da região critica
        print(f"{self.name}: Terminando loop")
        self.srv_conn.root.wait_everyone()
        print(f"{self.name}:\n{self.srv_conn.root.get_scoreboard_string()}")


def score_server_process():
    from rpyc.utils.server import ThreadedServer

    # ScoreService instanciado para compartilhamento de instancia entre clientes
    t = ThreadedServer(ScoreService(), port=PORT1, hostname="0.0.0.0")
    t.start()


def client_process(name):
    c = Client(name)
    c.game_finished.wait()
    print(f"{name}: Encerrando processo")


def coordinator_process():
    from rpyc.utils.server import ThreadedServer

    # CoordinatorService instanciado para compartilhamento de instancia entre clientes
    t = ThreadedServer(CoordinatorService(), port=PORT2, hostname="0.0.0.0")
    t.start()


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("Rodando localmente")
        srv_process = multiprocessing.Process(target=score_server_process)
        cl1_process = multiprocessing.Process(target=client_process, args=("Cliente1",))
        cl2_process = multiprocessing.Process(target=client_process, args=("Cliente2",))
        cl3_process = multiprocessing.Process(target=client_process, args=("Cliente3",))

        srv_process.start()
        time.sleep(1)
        cl1_process.start()
        time.sleep(1)
        cl2_process.start()
        time.sleep(1)
        cl3_process.start()

        srv_process.join()
    elif "server" == sys.argv[1]:
        score_server_process()
    elif "coordinator" == sys.argv[1]:
        coordinator_process()
    elif "client" == sys.argv[1]:
        if sys.argv == 2:
            print(f"python3 {sys.argv[0]} client CLIENT_NAME")
        client_process(sys.argv[2])
    else:
        print(f"usage: python3 {sys.argv[0]} {{server|coordinator|client CLIENT_NAME}}")
