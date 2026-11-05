#Substitua o valor de CC com o nome do compilador que voce usa: gcc ou g++
CC = g++
CFLAGS =   -g  -Wall 
LFLAGS = -lm

# 

main:    tabelaSimbolos.o main.o 
	$(CC) $(CFLAGS) $(LFLAGS) tabelaSimbolos.o main.o -o  main


main.o: main.cpp
	$(CC) $(CFLAGS) $(FLAGS) -c main.cpp -o main.o
                

tabelaSimbolos.o: tabelaSimbolos.cpp
	$(CC) $(CFLAGS) -c tabelaSimbolos.cpp -o tabelaSimbolos.o

clean:
	rm -f     *.o    main

cleanObj:
	rm -f   *.o  
