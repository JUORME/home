# LIBRERIAS

# install.packages("haven") 
# install.packages("foreign") 
# install.packages("dplyr") 
# install.packages("VIM")
# install.packages("mice")
# install.packages("dummies")
# install.packages("writexl")
# install.packages("caTools")
# install.packages("e1071")
# install.packages("naivebayes")
# install.packages("caret")
# install.packages("rpart")


## Importar Datos
library(haven)
dataset <- read_sav("D:/home/test/basemujeres5.sav")
View(dataset)

#Convertir a formato txt el archivo spss
library(foreign)
dataset = read.spss("D:/home/test/basemujeres5.sav",to.data.frame=TRUE)
write.table(dataset,"basemujeres5.txt")
str(dataset)
head(dataset)
summary(dataset)
#La 3 primeras columnas no suman al modelo, se eliminarán por esa razón


## Eliminar columnas innecesarias
dataset= dataset[,4:250]  #quitamos la primera columna

##Seleccionar columnas de interés
library(dplyr) 
dataset = dataset[, c('P1102', 'P17', 'P34', 'P39', 'P501', 'P503', 'P43', 'P48A')]


##Guardar en forma csv el conjunto training procesado
write.table(dataset, file = "D:/home/test/Data.csv", 
            sep=",", row.names = FALSE) #exportamos la tabla para futuros análisis


## Convertir variables categoricas a factores
library(dplyr) 
dataset <- dataset%>%mutate_if(is.character, as.factor)
str(dataset) #todas las que era char ahora son factor

## Analizar el comportamiento de los NAs en las variables
library(VIM)
aggr(dataset,
     col= c('green', 'red'), #colores del gráfico
     numbers = TRUE, 		#indicador de proporciones mostradas por números
     sortVars = TRUE, 		#ordena variables por apariencia de NAs de más a menos
     labels = names(dataset), #pone las etiquetas de acuerdo al nombre de las columnas
     cex.axis = 0.75, 		#ancho de barras
     gap = 1, 			#distancia entre gráficos
     ylab = c("Histograma de NAs", "Patrón"))   	#título de las variables 

## Analizar existencia de NAs con paquete Myce
library(mice)
md.pattern(dataset, rotate.names = T)
#Del gráfico, las últimas 5 columnas poseen NAs que se deben completar

## Imputar datos faltantes (solo con 5 iteraciones)
dataset <- mice(dataset, m=5, maxit=5, meth='pmm',seed=500)
summary(dataset)
dataset <- complete(dataset,1)
md.pattern(dataset, rotate.names = T)
#Ahora ya no hay NAs.
str(dataset)

## Escalar variables numéricas
library(dplyr)
dataset2 = mutate_if(dataset, is.numeric, scale)
class(dataset2)
str(dataset2)
str(dataset)

## Generar variables dummy para las variables categoricas 
library(dummies)
dataset2 <- dummy.data.frame(dataset2[,-1], sep = ".") 
dataset2$y = dataset$P1102  #ahora la variable respuesta está al final con "y"
table(dataset2$y)
str(dataset2$y)

##Guardar en forma csv la data procesada
library(writexl)
write_xlsx(dataset2,"D:/home/test/DataExcel.xlsx")


##Actualizar el dataset2 con el archivo excel exportado (para librar problemas en y)
library(readxl)
dataset2 <- read_excel("D:/home/test/DataExcel.xlsx")
dataset2 = as.data.frame(dataset2)
#View(dataset)
str(dataset2)


## Convertir variables categoricas a factores
library(dplyr) 
dataset2 <- dataset2%>%mutate_if(is.numeric, as.factor)
str(dataset2) #todas las que fueran char ahora son factores

#Codificar la variable respuesta
dataset2$y = factor(dataset2$y,
                    levels = c("Inaceptable pero no siempre debe ser castigada por la ley", "Inaceptable y siempre debe ser castigada por la ley"), 
                    labels = c(0, 1))  #la clase 1 es la más importante por ser delito
str(dataset2)

## Dividir los datos en conjunto de entrenamiento y conjunto de test
library(caTools)
set.seed(123)
split = sample.split(dataset2, SplitRatio = 0.75)
train = subset(dataset2, split == TRUE)
test= subset(dataset2, split == FALSE)

# Data para crear el modelo
table(train$y)   #existen 302 casos de "no castigada" y 580 de "si castigada"

#Proporción de casos por clase en variable respuesta
prop.table(table(train$y))   
summary(train)


##Guardar en forma csv el conjunto training procesado
write.table(train, file = "D:/home/test/Training_Procesada.csv", 
            sep=",", row.names = FALSE) #exportamos la tabla para futuros análisis

##Guardar en forma csv el conjunto testing procesado
write.table(test, file = "D:/home/test/Testing_Procesada.csv", 
            sep=",", row.names = FALSE) #exportamos la tabla para futuros análisis


######## Crear los modelos de clasificación con el conjunto de entrenamiento #########


# Creando el modelo con Support Vector Machines
library(e1071)
rfboth1 = svm(formula = y ~ ., 
              data = train,
              type = "C-classification",
              kernel = "poly",
              cost = 10)


# Creando el modelo con Naive Bayes
library(naivebayes)
rfboth2 = naiveBayes(formula = y ~ .,
                     data=train)

#Creando el modelo de regresión logística
rboth3 = glm(formula = y ~ .,
                 data = train, 
                 family = binomial)
prob_pred = predict(rboth3, type = "response",
                    newdata = test[,-38])
y_pred = ifelse(prob_pred> 0.5, 1, 0) # Vector con clases predichas


#Creando el modelo de Arbol de Decisión
library(rpart)
rboth4 = rpart(formula = y ~ ., 
                   data = train)
y_pred2 = predict(rboth4, newdata = test[,-38],
                 type = "class")

#Contruir Matriz de Confusion para todos los modelos
library(caret)
library(e1071)
matriz1=confusionMatrix(predict(rfboth1, test), test$y, positive = '1')  #svm
matriz2=confusionMatrix(predict(rfboth2, test), test$y, positive = '1')  #naive bayes
matriz3=confusionMatrix(as.factor(y_pred), test$y, positive = '1')       #logistica
matriz4=confusionMatrix(as.factor(y_pred2), test$y, positive = '1')      #arbol decision


##############Los resultados a tener en cuenta son los siguientes###############
#Modelo de SVM :         accuracy = 0.6531, sensitivity = 0.9275
#Modelo Naive Bayes:     accuracy = 0.6361, sensitivity = 0.8083
#Modelo Logístico:       accuracy = 0.6531, sensitivity = 0.9067
#Modelo Arbol Decision:  accuracy = 0.6599, sensitivity = 0.9637

#Por lo tanto, el mejor modelo es el de Arbol de Decisión pues obtiene el accuracy
#más alto de todos pero a la vez tiene también el sensitivity más alto de todos, 
#siendo este último excelente, ya que menos del 5% de los casos de la clase
#"Inaceptable y siempre debe ser castigada por la ley" la de interés por ser delitos.


test$Predicciones= y_pred2


##Guardar el la tabla final con pronósticos
write.table(test, file = "ResultadosArbol.csv", 
            sep=",", row.names = FALSE) #exportamos la tabla para futuros análisis

