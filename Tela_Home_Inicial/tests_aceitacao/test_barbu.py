from playwright.sync_api import sync_playwright, expect

def run_acceptance_tests():
    with sync_playwright() as p:
        # Iniciando o navegador (headless=False permite ver o teste rodando)
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()

        # 1. ACESSO AO SISTEMA
        print("Iniciando Teste: Acesso ao Sistema...")
        page.goto("http://localhost:5000") 

        # 2. TESTE DE ERRO: Tentar logar com senha errada (Cenário de Exceção)
        print("Executando UAT-02: Validação de Login Inválido")
        page.fill('input[type="email"]', 'cliente_teste@barbu.com')
        page.fill('input[type="password"]', 'senha_errada_123')
        page.click('text=Entrar')
        # Verifica se o sistema mantém o usuário na tela ou exibe alerta de erro
        expect(page.locator("text=Erro ao fazer login")).to_be_visible()
        
        # 3. TESTE DE SUCESSO: Login correto (Caminho Feliz)
        print("Executando UAT-01: Fluxo Completo de Sucesso")
        page.fill('input[type="password"]', '123456') # Corrigindo a senha
        page.click('text=Entrar')
        # Aguarda a navegação para a página inicial
        page.wait_for_url("**/home") 

        # 4. FLUXO DE AGENDAMENTO (Wizard de 3 Etapas)
        page.click('text=Agendar Horário')
        
        # Passo 0: Serviço
        page.click('text=Corte Padrão')
        page.click('text=Próximo')
        
        # Passo 1: Barbeiro
        page.click('text=Felipe')
        page.click('text=Próximo')
        
        # Passo 2: Horário e Confirmação
        page.click('text=10:00')
        page.click('text=Confirmar')

        # 5. VALIDAÇÃO DE NEGÓCIO (O objetivo final do app)
        # Verifica se a mensagem de sucesso aparece após a conclusão do fluxo
        expect(page.locator("text=Agendamento Confirmado! 🎉")).to_be_visible()
        
        print("Todos os testes de aceitação foram aprovados com sucesso!")
        browser.close()

if __name__ == "__main__":
    run_acceptance_tests()