##################################################################################################
# Project:     QWERTY
# Author:      Junior Ortiz
# Date:        2022
# Title:       Transformada discreta de fourier - Análisis de señales en tiempo real
# Description: La transformada discreta de fourier permite realizar el análisis espectral de una 
#               señal. Nos lleva del espacio de tiempo discrteo al espacio de frecuencias,
#               donde podemos obtener informacion sobre las componenter frecuenciales predominantes
#               de una señal.
##################################################################################################


#Librerias necesarias
#   !pip install IPython
#   !pip install numpy
#   !pip install scipy
#   !pip install matplotlib
#   !pip install winsound

from email.mime import audio
from pickle import FRAME
from ssl import CHANNEL_BINDING_TYPES
from this import d
from  IPython.display import Image
import numpy as np
import scipy.fftpack as fourier
import matplotlib.pyplot as plt
import scipy.io.wavfile as waves
import winsound


#   Definimos una funcion en tiempo discreto
gn = [0, 1, 2, 3, 4]
#   Calculamos la fft
gk = fourier.fft(gn)
gk

#   Calculamos la magnitud de la fft
m_gk = abs(gk)

#   Calculamos la fase de la fft
ph_gk = np.angle(gk)
print('Magnitud: ', m_gk)
print('Angle: ', ph_gk*180/np.pi)


#   IDENTIFICACION DE LA FRECUENCIA PREDOMINANTE EN SEÑAL DISCRETA

ts = 0.001
fs = 1/ts
w1 = 2*np.pi*60
w2 = 2*np.pi*223

n = ts*np.arange(0, 1000)
ruido = np.random.random(len(n))
x = 3*np.sin(w1*n)+2.3*np.sin(w2*n)+ruido

plt.plot(n,x,'.-')
plt.xlabel('Tiempo (s)', fontsize='14')
plt.ylabel('Amplitud', fontsize='14')
plt.show()


gk = fourier.fft(x)                     # Calculamos la fft
m_gk = abs(gk)                          # Calculamos la magnitud de la fft

F = fs*np.arange(0, len(x))/len(x)      # Definimos el vector de freccuencias

plt.plot(F,m_gk)
plt.xlabel('Frecuencia (hz)', fontsize='14')
plt.ylabel('Amplitud fft', fontsize='14')
plt.show()


#   IDENTIFICACION DE NOTAS MUSICALES CON AUDIO REAL

filename = 'd:/home/01_FFT_TiempoReal/data/rec_SOL.wav'
winsound.PlaySound(filename,winsound.SND_FILENAME)      # Reproducimos el sonido que vamos a cargar 

fs, data = waves.read(filename)                         # Leemos el archivo de audio del directorio
Audio_m = data[:,0]

L = len(Audio_m)

n= np.arange(0,L)/fs                                    # definimos un vector de tiempo de la misma longityug de la señal

plt.plot(n,Audio_m)
plt.show()

gk = fourier.fft(Audio_m)                               # Calculamos la fft de la señal de audio
M_gk = abs(gk)                                          # Tomamos la magnitud de la fft
M_gk = M_gk[0:L//2]                                     # Tomamos la mitad de los datos (recordar la simetria de la transformacion)

Ph_gk = np.angle(gk)
F = fs*np.arange(0, L//2)/L

plt.plot(F,M_gk)
plt.xlabel('Frecuencia (HZ)',fontsize='14')
plt.ylabel('Amplitud FFT',fontsize='14')
plt.show()

Posm = np.where(M_gk == np.max(M_gk))                   # Encontramos la posicion para lo cual la magnitud de fft es maxima
F_found = F[Posm]                                       # Identificamos la frecuencia asociada al valor del maximo de la magnitud de fft

if F_found > 135 and  F_found < 155:                    # Rango de frecuencias para la nota RE
    print("La nota es RE, con frecuencia: ",F_found)    
elif F_found > 190 and F_found < 210:                   # Rango de frecuencias para la nota SOL
    print("La nota es SOL, con frecuencia: ", F_found)
elif F_found > 235 and F_found < 255:                   # Rango de Frecuencias para la nota SI
    print("La nota es Si, con frecuencia: ", F_found)
elif F_found > 320 and F_found < 340:                   # Rango de frecuencias para la nota MI
    print("La nota es MI: con frecuencua: ", F_found)        





### 4. ANALISIS ESPECTRAL EN TIEMPO REAL USANDO ENTRADA DE MICROFONO ###########

# Librerias necesarias para instalar Pyaudio
#pip install pipwin
#pipwin install pyaudio

##### !pip install PyAudio

import matplotlib
import pyaudio as pa
import struct

matplotlib.use('tKAgg')

FRAMES = 1024*8                     # Tamaño del paquete a procesar
FORMAT = pa.paInt16                 # Formato de lectura Int 16 bits
CHANNELS = 1
fs = 44100                       # Frecuencia de muestreo tipica para audio



p = pa.PyAudio()


stream = p.open(
    format = FORMAT,
    channels = CHANNELS,
    rate = fs,
    input = True,
    frames_per_buffer=FRAMES
)


# Creamis una grafica con 2 subplots y configuramos los ejes

fig, (ax,ax1) = plt.subplot(2)

x_audio = np.arange(0,FRAMES,1)
x_fft = np.linspace(0, fs, FRAMES)

line, = ax.plot(x_audio, np.random.rand(FRAMES),'r')
line_fft = ax1.semilogx(x_fft, np.random.rand(FRAMES), 'b')

ax.set_ylim(-32500,32500)
ax.ser_xlim= (0,FRAMES)


Fmin = 1
Fmax = 5000

ax1.set_xlim(Fmin,Fmax)

fig.show()

F = (fs/FRAMES)*np.arange(0,FRAMES//2)                      # Creamos el vector de frecuencia para encontrar la frecuencia dominante

while True :
    data = stream.read(FRAMES)                              # Leemos paquetes de longitud FRAMES
    dataInt = struct.unpack(str(FRAMES) + 'h' , data)       # Convertimops los datos que se encuentran empaquetados en bytes

    line.set_ydata(dataInt)                                 # Asignamos los datos a la curva de la variacion temporal

    
    M_gk = abs(fourier.fft(dataInt)/FRAMES)                 # Calculamos la fft y la magnitud de la fft del paquete de datos

    ax1.set_ylim(0,np.max(M_gk+10))                         
    line_fft.set_ydata(M_gk)                                # Asignamos la magnitud de la fft a la curva del espectro

    M_gk = M_gk[0:FRAMES//2]                                # Tomamos la mitad del espectro para encontrar la frecuencia Dominante 
    Posm = np.where(M_gk == np.max(M_gk))                   # Encoentramos la frecuencia que corresponde con el maximo de M_gk
    f_found = F[Posm]

    print(int(F_found))                                     # Imprimimos el valor de la frecuencia dominante

    fig.canvas.draw()
    fig.canvas.flush_events()




















