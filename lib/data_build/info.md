keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias quantica

PASSWORD:
quantica

Introduzca la contraseña del almacén de claves:  
Volver a escribir la contraseña nueva: 
¿Cuáles son su nombre y su apellido?
  [Unknown]:  quantica
¿Cuál es el nombre de su unidad de organización?
  [Unknown]:  quantica
¿Cuál es el nombre de su organización?
  [Unknown]:  quantica
¿Cuál es el nombre de su ciudad o localidad?
  [Unknown]:  Leon
¿Cuál es el nombre de su estado o provincia?
  [Unknown]:  Guanajuato
¿Cuál es el código de país de dos letras de la unidad?
  [Unknown]:  MX
¿Es correcto CN=quantica, OU=quantica, O=quantica, L=Leon, ST=Guanajuato, C=MX?
  [no]:  si

Generando par de claves RSA de 2,048 bits para certificado autofirmado (SHA256withRSA) con una validez de 10,000 días
        para: CN=quantica, OU=quantica, O=quantica, L=Leon, ST=Guanajuato, C=MX
[Almacenando keystore.jks]