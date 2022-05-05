# Librerias necesarias 
library(haven)
library(data.table)
library(dplyr)
library(DescTools)

# Importar datos
df <- read.csv("https://raw.githubusercontent.com/JUORME/home/master/data/datosvrg.csv",fileEncoding = "UTF-8")
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

df_desc_servs <- df0_1 %>% 
						group_by(desc_servs) %>% 
						summarise("num"=n()) %>%
						arrange(desc(num)) %>%
						as.data.frame()


# Analizando los diagnosticos con la descripcion de enfermedades 

# Diagnostico 01
dg_1 <- df0_1 %>% select(edad, sexo, establec, servicio,
						 diagnost1, labconf1, codigo1)	

dg1 <- merge(dg_1, df_1, by.x = "codigo1", by.y="CIE10", all.x=TRUE) # Uniendo los df

dg1 <- dg1 %>% 
				group_by(DESCRIPCION.CIE) %>%
				summarise(n=n()) %>%
				arrange(desc(n)) %>%
				as.data.frame()	# Agrupar los datos en funcion a la descripcion de enfermedada
head(dg1,20)

# Diagnostico 02 
dg_2 <- df0_1 %>% select(edad, sexo, establec, servicio,
						  diagnost2, labconf2, codigo2)	
dg2 <- merge(dg_2, df_1, by.x = "codigo2", by.y="CIE10", all.x=TRUE) # Uniendo los df

dg2 <- dg2 %>% 
				group_by(DESCRIPCION.CIE) %>%
				summarise(n=n()) %>%
				arrange(desc(n)) %>%
				as.data.frame()	# Agrupar los datos en funcion a la descripcion de enfermedada
head(dg2,20)

# Diagnostico 03 
dg_3 <- df0_1 %>% select(edad, sexo, establec, servicio,
						  diagnost3, labconf3, codigo3)	
dg3 <- merge(dg_3, df_1, by.x = "codigo3", by.y="CIE10", all.x=TRUE) # Uniendo los df

dg3 <- dg3 %>% 
				group_by(DESCRIPCION.CIE) %>%
				summarise(n=n()) %>%
				arrange(desc(n)) %>%
				as.data.frame()	# Agrupar los datos en funcion a la descripcion de enfermedada
head(dg3,20)

# Diagnostico 04
dg_4 <- df0_1 %>% select(edad, sexo, establec, servicio,
						  diagnost4, labconf4, codigo4)	
dg4 <- merge(dg_4, df_1, by.x = "codigo4", by.y="CIE10", all.x=TRUE) # Uniendo los df

dg4 <- dg4 %>% 
				group_by(DESCRIPCION.CIE) %>%
				summarise(n=n()) %>%
				arrange(desc(n)) %>%
				as.data.frame()	# Agrupar los datos en funcion a la descripcion de enfermedada
head(dg4,20)