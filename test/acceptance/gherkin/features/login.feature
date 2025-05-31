Feature: Iniciar sesión en la aplicación
  Como usuario de TempoSage
  Quiero iniciar sesión en la aplicación
  Para poder acceder a mis datos personales

  Scenario: Iniciar sesión con credenciales válidas
    Given estoy en la pantalla de "login"
    When ingreso "test@example.com" como email
    And ingreso "12345678" como contraseña
    And presiono el botón "Iniciar Sesión"
    Then debería ver la pantalla de "dashboard"
    And debería ver el mensaje "Bienvenido"

  Scenario: Iniciar sesión con email inválido
    Given estoy en la pantalla de "login"
    When ingreso "email_invalido" como email
    And ingreso "12345678" como contraseña
    And presiono el botón "Iniciar Sesión"
    Then debería ver un mensaje de error "Email inválido"
    And debería permanecer en la pantalla de "login"

  Scenario: Iniciar sesión con contraseña incorrecta
    Given estoy en la pantalla de "login"
    When ingreso "test@example.com" como email
    And ingreso "contraseña_incorrecta" como contraseña
    And presiono el botón "Iniciar Sesión"
    Then debería ver un mensaje de error "Credenciales inválidas"
    And debería permanecer en la pantalla de "login" 