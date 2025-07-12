# lorawan-network-backend
Esse repositório contém o back-end que irá gerenciar os dados de uma rede de sensores. Foi visto a necessidade de expor os dados da rede de sensores para que outras pessoas conseguissem acessar.
Com isso, foi feita uma API que irá expor os dados dos sensores e também receber novos dados. Caso os clientes queiram manter os dados atualizados em tempo real, também podem se conectar ao servidor Socketio,
que manda uma mensagem sempre que um dado novo é adicionado no banco de dados. Também foi feito uma aplicação em Flutter que utiliza essa API para obter os dados dos sensores, é possível encontrá-la [aqui](https://github.com/LAB-PDS/dashboard-flutter).

# Tabela de conteúdos
- [Arquitetura e stack](#arquitetura-e-stack)
- [Status](#status)
- [Estrutura](#estrutura)
- [Execução do código](#execução-do-código)

# Arquitetura e stack

**Flask**

*O back-end está sendo desenvolvido utilizando o framework [Flask](https://flask.palletsprojects.com/en/3.0.x/) em python, este framework é conhecido pela sua simplicidade e pela rapidez no desenvolvimento, ou seja, não é necessário realiar diversas configurações e a quantidade de arquivos do projeto é menor do que em outros frameworks.*

**PostgreSQL**

*Para o banco de dados foi escolhido utilizar [PostgreSQL](https://www.postgresql.org/) devido ao ser melhor desempenho com atualizações de dados frequentes e consultas complexas. Como os dados dos sensores irão chegar frequentemente, essa escolha pareceu mais adequada ao projeto.*

# Status
- [x] Criação da API para expor os dados.
- [x] Utilizar Socketio para se comunicar com os clientes.
- [x] Gestão de erros.
- [x] Métodos de autenticação.
- [ ] Testes
- [ ] Melhorias
- [ ] Documentação

# Estrutura

A aplicação está organizada da seguinte forma:

![fluxo_backend drawio](https://github.com/LAB-PDS/lorawan-network-backend/assets/39863490/2f5035b6-ab80-4ac8-bdcd-06b70caeedc8)

Para estruturar os arquivos foi utilizado o padrão de modularização, em que o projeto é separado em módulos e são utilizados blueprints para manter o código organizado. Um exemplo dessa estrutura pode ser visto abaixo:

```
my_flask_project/
|-- app/
    |-- __init__.py
    |-- module1/
    |   |-- __init__.py
    |   |-- views.py
    |   |-- models.py
    |-- module2/
    |   |-- __init__.py
    |   |-- views.py
    |   |-- models.py
```

Neste projeto por exemplo, um módulo seria para a API e o outro módulo seria o Socketio. 

### Autenticação
Para realizar a autenticação na API, foi utilizado tanto JWT quanto uma API key. Ambos os métodos são configurados no arquivo config.py, onde é possível definir as chaves correspondentes para cada um deles.
É possível encontrar mais informações sobre JWT neste [site](https://jwt.io/).

### Endpoints e métodos HTTP
- Endpoint: 'api/dados/id':
    - Métodos suportados:
        - GET: Obter id para uma placa.
    - Observações:
        - É necessário enviar a chave da api para ser autorizado.
- Endpoint: 'api/dados/placas':
    - Métodos suportados:
        - GET: Obter dados sobre as placas. (Local, latitude, longitude, etc.)
        - POST: Realizar o cadastro de uma placa. (Colocar a latitude, longitude, nome do local, etc.)
    - Parâmetros:
        - Os parâmetros que podem ser enviados são as colunas da tabela das placas, para filtrar de acordo com o parâmetro desejado.
- Endpoint: 'api/dados/sensores':
    - Métodos suportados:
        - GET: Obter todos os dados dos sensores das placas
        - POST: Enviar os dados dos sensores de uma placa.
    - Parâmetros:
        - 'data_inicial' (opcional): filtro para obter os dados a partir de uma certa data.
        - 'data_final' (opcional): filtro para obter os dados até uma certa data.
        - 'local' (opcional): filtro para obter os dados de um determinado local.
        - 'dias_passados' (opcional): filtro para obter os dados até um certo número de dias anteriores.
        - 'id_placa' (opcional): filtro para obter os dados de somente uma placa.
- Endpoint: 'api/dados/local':
    - Métodos suportados:
        - GET: Obter os dados dos locais.
    - Parâmetros:
        - 'data_inicial' (opcional): filtro para obter os dados a partir de uma certa data.
        - 'data_final' (opcional): filtro para obter os dados ate uma certa data.
        - 'local' (opcional): filtro para obter os dados de um determinado local.
        - 'dias_passados' (opcional): filtro para obter os dados até um certo número de dias anteriores.
    - Observações:
        - Além dos dados normais dos sensores, também é retornado as métricas de cada sensores, informando o valor máximo, valor mínimo e a média. Essas métricas são para o periodo de tempo do parâmetro 'dias_passados'.
        - Caso o valor do parâmetro 'dias_passados' não seja específicado ou seja maior ou igual a 30, invés de retornar todos os dados dos sensores, vão ser retornados apenas as médias, valores máximos e mínimos de cada dia.
- Endpoint: 'usuarios/cadastro':
    - Métodos suportados:
        - POST: Cadastrar um novo usuário.
    - Parâmetros:
        - 'username': Nome do usuário.
        - 'password': Senha.
    - Observações:
        - Ao cadastrar um novo usuário, o que será armazenado no banco de dados é o hash da senha.
- Endpoint: 'usuarios/&lt;username&gt;':
    - Métodos suportados:
        - DELETE: Deletar um usuário.
    - Parâmetros:
        - 'username': Nome do usuário.
- Endpoint: 'usuarios':
    - Métodos suportados:
        - GET: Obter os dados de todos os usuários.
- Endpoint: 'usuario':
    - Métodos suportados:
        - GET: Obter os dados de um usuário.
    - Parâmetros:
        - 'username': Nome do usuário.
- Endpoint: 'login':
    - Métodos suportados:
        - GET: Obter o token jwt.
    - Parâmetros:
        - 'username': Nome do usuário.
        - 'password': Senha.
    - Observações:
        - Caso o usuário seja validado com sucesso, será retornado o token jwt com duração de 1 dia até ser expirado.

### Requisições

Exemplo de requisição para api/dados/id (GET):
```
# Header
"x-api-key": {API_KEY}

# Requisição
http://127.0.0.1:5000/api/dados/id

# Resposta (é retornado o novo id da placa)
1
```

Exemplo de requisição para api/dados/placas (GET):
```
# Requisição
http://127.0.0.1:5000/api/dados/placas

# Resposta
[
    {
        "id_placa": 1,
        "iluminacao": true,
        "latitude": 321.0,
        "local": "TESTE",
        "longitude": 123.0,
        "temperatura_do_ar": true,
        "temperatura_do_solo": true,
        "umidade_do_ar": true,
        "umidade_do_solo": true
    },
    ...
]
```

Exemplo de requisição para api/dados/placas (POST):
```
# Body
{
    "id_placa": 1,
    "latitude": 123,
    "longitude": 321,
    "local": "Teste",
    "temperatura_do_ar": true,
    "temperatura_do_solo": true,
    "umidade_do_ar": true,
    "umidade_do_solo": true,
    "iluminacao": true
}
```


Exemplo de requisição para api/dados/sensores (GET):

```
# Requisição (Caso queira aplicar algum filtro, basta adicionar os parâmetros na requisição)
http://127.0.0.1:5000/api/dados/sensores

# Resposta
[
    {
        "data": [],
        "id_placa": 1,
        "local": "Teste",
        "latitude": 123,
        "longitude": 321,
        "temperatura_do_solo": [],
        "temperatura_do_ar": [],
        "umidade_do_ar": [],
        "umidade_do_solo": [],
        "iluminacao": []
    },
    ...
]
```


Exemplo de requisição para api/dados/sensores (POST):
```
# Body
{
    "id_placa": 1,
    "temperatura_do_ar": 29,
    "temperatura_do_solo": 30,
    "umidade_do_ar": 50,
    "umidade_do_solo": 50,
    "iluminacao": 300,
    "data": "2024-07-30T00:00:00"
}   
```


Exemplo de requisição para api/dados/local (GET):
```
{
    "dados: [
                {
                    "data": [],
                    "local": "Teste",
                    "latitude": 123,
                    "longitude": 321,
                    "temperatura_do_solo": [],
                    "temperatura_do_ar": [],
                    "umidade_do_ar": [],
                    "umidade_do_solo": [],
                    "iluminacao": []
                },
                ...
            ],
    "metricas": {
        "iluminacao": {
            "media": 321,
            "valor_maximo": 325,
            "valor_minimo": 300
        },
        "temperatura_do_ar": {
            "media": 32,
            "valor_maximo": 34,
            "valor_minimo": 29
        },
        ...
    }
}
```


Exemplo de requisição para usuarios/cadastro (POST):
```
# Body
{
    "username": "userteste",
    "password": "senhateste"
}

# Resposta
{
    "data": {
        "id": 35,
        "password": "scrypt:32768:8:1$7QEty3QJgWz99sSX$7ae3a768782722110e6a4c3bb0c27a1527c288227d0a2148c1969592c6b7b971fa3beeeaae5d16766d56072bc8d4d1b3e08de51e824ec7b07fc4c25d216c1a0b",
        "role": "user",
        "username": "userteste"
    },
    "message": "Usuário cadastrado com sucesso."
}
```


Exemplo de requisição para usuarios/<username> (DELETE):
```
# Body
{
    "username": "userteste"
}

# Resposta
{
    "data": {
        "id": 35,
        "password": "scrypt:32768:8:1$7QEty3QJgWz99sSX$7ae3a768782722110e6a4c3bb0c27a1527c288227d0a2148c1969592c6b7b971fa3beeeaae5d16766d56072bc8d4d1b3e08de51e824ec7b07fc4c25d216c1a0b",
        "role": "user",
        "username": "userteste"
    },
    "message": "Usuário deletado com sucesso."
}
```

Exemplo de requisição para usuarios (GET):
```
# Resposta
{
    "data": [
        {
            "id": 2,
            "password": "scrypt:32768:8:1$BDZ8aU3ni5Q9RWSB$dc293464fe72d61f5ac5c46a8caf763ec99f11c4550f362cdfbf76bef81a7bf96246fc6b7d47353a3acc3359f25b52a943c78af2691394cac25c6ad99d6c76c1",
            "role": "user",
            "username": "usuario"
        },
        {
            "id": 3,
            "password": "scrypt:32768:8:1$m1nqhI8QNK3Der5p$9a508e7741e69243e1273d784bfca7bb7a0e6b3498c38c472ce98289b0074c6e0cca43d7f07b814c8240ca96cccbbb6cb7da0f43f4d32cb5da165b1af024e066",
            "role": "user",
            "username": "usuario1"
        },
        ...
}
```


Exemplo de requisição para usuario (GET):
```
# Header
Authorization: Bearer {jwt}

# Resposta (O usuário é obtido pelo jwt)
{
    "data": {
        "id": 1,
        "password": "scrypt:32768:8:1$POITP4NFkugME4ZV$332039432864b2605a36a4ed72f7b1aa8a28f793903801a8677e835f2d75826a7adb8674486d7fab4ead55c749baf9c6eef70adb01e7258d2d24c22bc4d86f95",
        "role": "admin",
        "username": "admin"
    },
    "message": "Dados dos usuários obtidos com sucesso."
}
```


Exemplo de requisição para login (GET):
```
# Requisição (Necessário enviar uma autenticação básica)
# Exemplo utilizando curl
curl usuario:senha http://127.0.0.1:5000/login

#Resposta
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcyMjQyOTI3NywianRpIjoiNjE5Y2U0NmUtYjJmYS00ZjA1LWI1ZTMtNDhmYjI3Y2U5M2FlIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImFkbWluIiwibmJmIjoxNzIyNDI5Mjc3LCJjc3JmIjoiMTU1YmExN2UtYzhmZi00Y2NhLWEzYzYtYjg3Y2NiZWFhMTBjIiwiZXhwIjoxNzIyNTE1Njc3LCJyb2xlIjoiYWRtaW4ifQ.gIK2I2lYU0_kSslmsktKXBMjIpkY3p-5D6NDEJpt77U",
    "message": "Usuário validado com sucesso.",
    "role": "admin"
}
```


### Códigos de Resposta HTTP
Os códigos de resposta foram baseados no site da Mozilla, disponível [aqui](https://developer.mozilla.org/pt-BR/docs/Web/HTTP/Status).

# Execução do código

Para iniciar o back-end basta seguir os seguintes passos:

```
# Clone este repositório
git clone git@github.com:LAB-PDS/lorawan-network-backend.git

# Ative o ambiente virtual
source venv/bin/activate

# Acesse a pasta do projeto e execute o comando abaixo para instalar todas as dependências, que estão no arquivo requirements.txt
pip install -r requirements.txt

# Execute a aplicação
python run.py
```

