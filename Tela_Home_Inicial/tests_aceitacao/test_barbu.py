from playwright.sync_api import sync_playwright
import time

def run_acceptance_tests():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=500)
        
        # 1. Travar a tela exatamente no tamanho do seu ResponsiveWrapper
        context = browser.new_context(viewport={"width": 450, "height": 800})
        page = context.new_page()

        print("Iniciando Teste: Acesso ao Sistema...")
        page.goto("http://localhost:65394/") 
        
        # Aguarda 4 segundos para o Flutter terminar de carregar a SplashScreen
        page.wait_for_timeout(10000)

        # ===========================================================================
        # 2. TESTE DE ERRO: Validação de Login Inválido
        # ===========================================================================
        print("Executando UAT-02: Validação de Login Inválido")
        
        # Clica no topo da tela apenas para o Canvas ganhar foco do teclado
        page.mouse.click(225, 20)
        
        # O Tab pula direto para o campo E-mail
        page.keyboard.press("Tab")
        page.keyboard.type("teste@gmail.com")
        
        # Pula para o campo Senha
        page.keyboard.press("Tab")
        page.keyboard.type("teste12344545")
        
        # Botão ENTRAR (Coordenada X centralizada, Y descendo a tela)
        page.mouse.click(225, 560)
        page.wait_for_timeout(2000)
        
        # Recarrega a página para limpar os dados e resetar a interface
        page.reload()
        page.wait_for_timeout(4000)

        # ===========================================================================
        # 3. TESTE DE SUCESSO: Login correto
        # ===========================================================================
        print("Executando UAT-01: Fluxo Completo de Sucesso")
        page.mouse.click(225, 20)
        
        page.keyboard.press("Tab")
        page.keyboard.type("teste@gmail.com")
        page.wait_for_timeout(1000)
        page.keyboard.press("Tab")
        page.keyboard.type("teste123") 
        
        # Botão ENTRAR
        page.mouse.click(225, 560)
        
        # Aguarda 3 segundos para o Firebase validar e mudar para a Home
        page.wait_for_timeout(3000) 

        # ===========================================================================
        # 4. FLUXO DE AGENDAMENTO (Wizard de 3 Etapas)
        # ===========================================================================
        print("Navegando no fluxo de Agendamento...")
        
        # Botão AGENDAR (Card esquerdo na Grid da Home)
        page.mouse.click(120, 470)
        page.wait_for_timeout(2000)
        
        # Passo 0: Serviço "Corte Padrão" (Primeiro item da lista)
        page.mouse.click(225, 180)
        # Botão PRÓXIMO (Rodapé fixo)
        page.mouse.click(225, 750)
        page.wait_for_timeout(1000)
        
        # Passo 1: Barbeiro "Felipe" (Primeiro item da lista)
        page.mouse.click(225, 180)
        # Botão PRÓXIMO
        page.mouse.click(225, 750)
        
        # Aguarda 2 segundos extras para o app consultar horários no Firestore
        page.wait_for_timeout(2000)
        
        # Passo 2: Horário "10:00" (Segundo chip da Grid de horários)
        page.mouse.click(172, 380)
        # Botão CONFIRMAR (Rodapé fixo)
        page.mouse.click(225, 750)
        page.wait_for_timeout(2000)

        # ===========================================================================
        # 5. VALIDAÇÃO FINAL
        # ===========================================================================
        print("Todos os testes de aceitação foram executados! Verifique o pop-up na tela.")
        page.wait_for_timeout(3000)
        browser.close()

if __name__ == "__main__":
    run_acceptance_tests()