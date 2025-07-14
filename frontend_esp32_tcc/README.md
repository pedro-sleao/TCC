# dashboard-flutter
Dashboard em Flutter para visualizar os dados dos nodos de uma rede de sensores.

# Arquitetura e stack
A aplicação está sendo desenvolvida em Flutter, que permite construir com o mesmo código uma versão para web e uma para mobile.
Para realizar o gerenciamento dos estados está sendo utilizado o [Cubit](https://pub.dev/packages/flutter_bloc), que é um subconjunto do padrão Bloc. Este padrão foi escolhido por seu desempenho superior à medida que a aplicação cresce,
além de oferecer uma organização melhor ao projeto.

Detalhes da stack:
- Os pacotes utilizados na aplicação podem ser vistos no arquivo pubspec.yaml. Para instalar todos os pacotes necessários basta executar o seguinte comando no terminal: ```flutter pub get```.
- A aplicação realiza requisições em uma API feita em flask para obter todos os dados da rede de sensores. O repositório com a documentação desta API pode ser visto [aqui](https://github.com/LAB-PDS/lorawan-network-backend).
- A aplicação se conecta a um Socketio para receber mensagens sempre que o servidor receber algum dado novo. Esse servidor Socketio pode ser encontrado no mesmo repositório da API.
- Para realizar a autenticação do usuário a aplicação utiliza JSON Web Tokens (JWT), ao realizar a requisição no servidor é obtido um JWT que é armazenado localmente no dispositivo do usuário.


# Status
- [x] Primeira versão da UI.
- [x] Gerenciamento dos estados com Cubit.
- [x] Integração com o back-end.
- [x] Construir o mapa para visualizar os locais da rede de sensores.
- [x] Colocar marcadores nos locais em que os sensores estão posicionados.
- [x] Implementar a página de cadastro de novas placas.
- [x] Implementar o sistema de autenticação de usuários.
- [ ] Melhorias
- [ ] Testes
- [ ] Documentação

# Estrutura
A estrutura da aplicação pode ser vista como uma divisão em três blocos principais:
- Repository: Responsável por gerenciar a lógica de acesso a dados, seja a partir de APIs, bancos de dados locais, ou outras fontes. Ele atua como uma camada intermediária entre a fonte de dados e o restante da aplicação, fornecendo métodos para obter, armazenar e atualizar dados.
- Cubit: Gerencia o estado da aplicação. Ele recebe eventos do usuário ou de outras partes da aplicação, realiza a lógica necessária e emite novos estados.
- Presentation: Contém a interface de usuário e a lógica de apresentação. É onde os estados gerados pelo Cubit são transformados em widgets que compõem a interface da aplicação.

As pastas estão estruturadas seguindo o modelo Type/Domain, que consiste em nomear os arquivos de acordo com sua funcionalidade/tipo. Esse padrão pode ser visto abaixo:
```
--lib
  |--presentation
  |--widgets
  |--data
  |--cubit
  |-- ...
```


# Execução do código

Comandos para executar o código:
- Para abrir a aplicação na web execute:
```flutter run -d web-server```
- Para gerar um apk para android execute:
```fluter build apk --release```

Como a aplicação faz requisições na API e se conecta ao Socketio, é necessário ter uma conexão com a internet para conseguir visualizar os dados. Caso a aplicação e o back-end estejam hospedados no mesmo local, é possível utilizar os endereços de ip 127.0.0.1 para web e 10.0.2.2 para um emulador android. Esses são os endereços de ip padrões para o localhost.

