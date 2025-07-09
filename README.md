# Sistema Embarcado com comunicação WiFi para monitoramento de variáveis da água para Carcinicultura

Este projeto visa desenvolver um sistema embarcado com conectividade Wi-Fi para monitoramento remoto de variáveis da água, com foco em aplicações na carcinicultura. O sistema coleta dados de sensores, realiza a transmissão via protocolo MQTT e oferece suporte para atualizações OTA.

## Sensores

- **Sensor de temperatura DS18B20**
- **Sensor de PH Ph4502c**
- **Sensor de TDS**
- **Sensor de turbidez**

## Status do projeto

### Firmware

- [x] OTA
- [x] Sensores
- [x] SmartConfig (Conectar a esp ao WiFi utilizando o celular)
- [x] WiFi
- [x] MQTT
- [x] Usar o RTC para enviar os dados periodicamente

### PCB

- [x] Definir se os sensores serão alimentados diretamente pela ESP32 ou por uma fonte externa -> sensor de pH pelos 5V do módulo da bateria e os outros sensores pela esp
- [x] Decidir o que será utilizado para adaptar a saída do sensor de PH (0 - 5V) para a entrada do ADC da ESP (0 - 3.3V) -> divisor de tensão
- [x] Finalizar o esquemático com todos os componentes
- [x] Layout da Placa

### Front-end

Desenvolvimento ainda não iniciado.

### Back-end

Desenvolvimento ainda não iniciado.
