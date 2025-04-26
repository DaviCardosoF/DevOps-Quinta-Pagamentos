from flask import Flask, request, jsonify
from flask import send_from_directory
import requests
import os

app = Flask(__name__)

API_PHP_URL = "http://php-app/produtos.php"

# Lista temporária para simular registros de pagamento
registros_pagamento = []

@app.route("/api-flask/pagar", methods=["POST"])
def registrar_pagamento():
    try:
        dados = request.get_json()
        print("Dados recebidos:", dados)  # Print para verificar os dados recebidos
        id_produto = dados.get("id_produto")
        valor = dados.get("valor")

        if not id_produto or not valor:
            return jsonify({"erro": "Informe id_produto e valor"}), 400

        print("Consultando produtos na API PHP...")
        response = requests.get(API_PHP_URL)
        print("Resposta da API PHP:", response.text)  # Print para ver o que a API PHP retornou

        if response.status_code != 200:
            return jsonify({"erro": "Falha ao consultar API PHP"}), 500

        try:
            produtos = response.json()
        except ValueError as e:
            return jsonify({"erro": f"Erro ao processar resposta da API PHP: {str(e)}"}), 500

        print("Produtos recebidos:", produtos)  # Verificando a lista de produtos

        produto = next((p for p in produtos if str(p["id"]) == str(id_produto)), None)

        if not produto:
            return jsonify({"erro": "Produto não encontrado"}), 404

        # Verificar se o valor inserido é menor que o preço do produto
        if float(valor) < float(produto["preco"]):
            return jsonify({"erro": "Valor inserido é menor que o preço do produto"}), 400

        # Se o valor for maior que o preço, calcular o troco
        if float(valor) > float(produto["preco"]):
            troco = float(valor) - float(produto["preco"])
            return jsonify({"mensagem": f"Pagamento processado. Devolver troco de {troco:.2f}"}), 200

        payload = {
            "id_produto": id_produto,
            "nome_produto": produto["nome"],
            "valor": valor
        }

        print("Enviando dados para registrar pagamento...")
        resposta_php = requests.post("http://php-app/registrar_pagamento.php", json=payload)
        print("Status code da resposta PHP:", resposta_php.status_code)  # Verificar o status da resposta

        if resposta_php.status_code != 200:
            return jsonify({"erro": f"Erro ao registrar pagamento na API PHP: {resposta_php.text}"}), 500

        try:
            retorno_php = resposta_php.json()
        except ValueError as e:
            return jsonify({"erro": f"Erro ao processar resposta da API PHP: {str(e)}"}), 500

        return jsonify({
            "mensagem": "Pagamento processado",
            "retorno_php": retorno_php
        })

    except Exception as e:
        return jsonify({"erro": str(e)}), 500

@app.route("/api-flask/pagamentos", methods=["GET"])
def listar_pagamentos():
    return jsonify(registros_pagamento)

@app.route("/")
def servir_html():
    return send_from_directory(os.path.join(app.root_path, "index"), "index.html")    

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

