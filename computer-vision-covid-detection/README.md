## Using Convolutional Neural Network for Covid-19 diagnostic

### Authors 
* Milton Alexandre Souza Demarchi
* Yuri dos Reis de Oliveira

### Description

Using the COVID-19 Radiography Database [1] and starting from an existing model [2], we first corrected some bugs of the base model and reached 94,46% accuracy (original).

Changing the neural network achitecture and converting the image to grayscale before training the model, we reduced the time and performance requirements to train the model and reached 95,32% accuracy (modificado)

Finally, using densenet-121 and preloading imagenet weights before training, we reached 98,58% accuracy (densenet)

There is also a presentation in pt-br

[1] https://www.kaggle.com/datasets/tawsifurrahman/covid19-radiography-database
[2] https://www.kaggle.com/code/jahid85/covid-19-detection-using-cnn-jahid
