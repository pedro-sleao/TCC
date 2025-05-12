# Sistema Embarcado com comunicação WiFi para monitoramento de variáveis da água para Carcinicultura

Este projeto visa desenvolver um sistema embarcado com conectividade Wi-Fi para monitoramento remoto de variáveis da água, com foco em aplicações na carcinicultura. O sistema coleta dados de sensores, realiza a transmissão via protocolo MQTT e oferece suporte para atualizações OTA.

## Sensores

- **DS18B20**
    - Temperatura
- **Ph4502c**
    - PH
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

- [ ] Definir se os sensores serão alimentados diretamente pela ESP32 ou por uma fonte externa
- [ ] Decidir o que será utilizado para adaptar a saída do sensor de PH (0 - 5V) para a entrada do ADC da ESP (0 - 3.3V)
- [ ] Finalizar o esquemático com todos os componentes
- [ ] Layout da Placa

### Front-end

Desenvolvimento ainda não iniciado.

### Back-end

Desenvolvimento ainda não iniciado.
