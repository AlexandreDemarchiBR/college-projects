import cv2
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' # suprime warnings do tensorflow
import matplotlib.pyplot as plt
import numpy as np
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow import keras
from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense
from keras.models import Sequential
from keras.optimizers import Adamax
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay, classification_report


# Função para carregar imagens
def load_images(path, urls, target, image_size=(100, 100)):
    images = []
    labels = []
    for i in range(len(urls)):
        img_path = os.path.join(path, urls[i])
        img = cv2.imread(img_path)
        img = cv2.resize(img, image_size)
        img = img / 255.0
        images.append(img)
        labels.append(target)
    images = np.asarray(images)
    return images, labels


# Carregando imagens para as três classes
covid_path = "COVID-19_Radiography_Dataset/COVID/images"
covid_urls = os.listdir(covid_path)
covid_images, covid_targets = load_images(covid_path, covid_urls, 0)

viral_pneumonia_path = "COVID-19_Radiography_Dataset/Viral Pneumonia/images"
viral_pneumonia_urls = os.listdir(viral_pneumonia_path)
viral_pneumonia_images, viral_pneumonia_targets = load_images(viral_pneumonia_path, viral_pneumonia_urls, 1)

normal_path = "COVID-19_Radiography_Dataset/Normal/images"
normal_urls = os.listdir(normal_path)
normal_images, normal_targets = load_images(normal_path, normal_urls, 2)

# Concatenando dados e rótulos
data = np.concatenate([covid_images, viral_pneumonia_images, normal_images])
targets = np.concatenate([covid_targets, viral_pneumonia_targets, normal_targets])

# Codificando rótulos de forma one-hot
targets = tf.keras.utils.to_categorical(targets, num_classes=3)

# Dividindo em conjuntos de treinamento e teste
x_train, x_test, y_train, y_test = train_test_split(data, targets, test_size=0.2)

# Definindo o modelo
model = Sequential([
    tf.keras.applications.densenet.DenseNet121(include_top=False,weights='imagenet',input_shape=(100, 100, 3),pooling='max',classifier_activation='softmax'),
    Dense(3, activation= 'softmax')
])

model.summary()

model.compile(optimizer=Adamax(learning_rate= 0.001), loss='categorical_crossentropy', metrics=['accuracy'])

# Treinando o modelo
history = model.fit(x_train, y_train, batch_size=32, epochs=10, validation_data=(x_test, y_test))

# Plots de precisão e perda
plt.plot(history.history['accuracy'], label='train accuracy')
plt.plot(history.history['val_accuracy'], label='test accuracy')
plt.legend()
plt.show()


plt.plot(history.history['loss'], label='train loss')
plt.plot(history.history['val_loss'], label='test loss')
plt.legend()
plt.show()


# preparando para obter metricas
yp_train = model.predict(x_train)
yp_train = np.argmax(yp_train, axis = 1)
yr_train = np.argmax(y_train, axis = 1)

yp_test = model.predict(x_test)
yp_test = np.argmax(yp_test, axis = 1)
yr_test = np.argmax(y_test, axis = 1)

#Matriz de confusão
cm_train = confusion_matrix(yr_train, yp_train)
t1 = ConfusionMatrixDisplay(cm_train,display_labels=['Covid','Viral Pneumonia','Normal'])

cm_test = confusion_matrix(yr_test, yp_test)
t2 = ConfusionMatrixDisplay(cm_test,display_labels=['Covid','Viral Pneumonia','Normal'])

t1.plot()
plt.title('Matriz de confusão do treinamento')
plt.savefig('d_confusion_matrix_train_5.png')
t2.plot()
plt.title('Matriz de confusão do teste')
plt.savefig('d_confusion_matrix_test_5.png')


print("\nMatriz de confusão do treino")
print(cm_train)
print("\nMatriz de confusão do teste")
print(cm_test)

# classification report
print("/nClassification Report do treino\n")
print(classification_report(yr_train, yp_train,digits=4))

print("/nClassification Report do teste\n")
print(classification_report(yr_test, yp_test,digits=4)) 

model.save("models/CovidDiagnostic_densenet5.keras")