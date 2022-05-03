# Librerias necesarias 
library(haven)
library(data.table)
library(dplyr)
library(DescTools)

# Importar datos
df <- read.csv("https://raw.githubusercontent.com/JUORME/home/master/data/datosvrg.csv")
df_1 <- read.csv("https://raw.githubusercontent.com/JUORME/home/master/data/cies_10.csv")
	df_1 <- df_1 %>% select(CIE10,DESCRIPCION.CIE)



# Seleccion de columnas de df

df0_1 <- df %>% select (edad, sexo, establec, servicio,
						 diagnost1, labconf1, codigo1,
						 diagnost2, labconf2, codigo2,
						 diagnost3, labconf3, codigo3,
						 diagnost4, labconf4, codigo4,
						 diagnost5, labconf5, codigo5,
						 diagnost6, labconf6, codigo6,
						 desc_servs
	)

# Rango de edades de los pacientes 
df_edad <- Freq(df0_1$edad)
df_sexo <- Freq(df0_1$sexo)
df_establec <- Freq(df0_1$establec)
df_servicio <- Freq(df0_1$servicio)

df_desc_servs <- Freq(df0_1$desc_servs)