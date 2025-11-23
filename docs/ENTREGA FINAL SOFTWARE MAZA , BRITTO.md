#
<a name="_hlk151638552"></a>   **ENTREGA FINAL DE INGENIERÍA DE SOFTWARE II**

**DESARROLLO DE UNA APLICACIÓN PARA EL CONTROL DE CITAS DE UN CONSULTORIO MÉDICO** 

**:**

<a name="_gjdgxs"></a>**HAROLD DAVID BRITTO MORALES**

**DIEGO ARMANDO MAZA CHURIO**

[**Maribel Romero Mestre**](https://aulaweb.unicesar.edu.co/user/view.php?id=55584&course=314051)


**UNIVERSIDAD POPULAR DEL CESAR** 

**Valledupar, Cesar, Colombia**

**2023**
# **Tabla de contenido**
[1.	MODELOS DEL SISTEMA.	3](#_toc151682173)

[1.1	IDENTIFICACION DEL PROBLEMA	3](#_toc151682174)

[1.2	DESCRIPCIÓN DETALLADA DEL SISTEMA O APLICACIÓN	3](#_toc151682175)

[1.3 MODELO DE REQUERIMIENTOS.	4](#_toc151682176)

[1.3.1 REQUERIMIENTOS FUNCIONALES	4](#_toc151682177)

[1.3.2. REQUERIMIENTOS NO FUNCIONALES (RNF)	8](#_toc151682178)

[1.4 MODELO DE CASOS DE USO.	9](#_toc151682179)

[1.4.1 DIAGRAMAS DE CASO DE USO:	9](#_toc151682180)

[1.4.2 DESCRIPCION DE CASO DE USO:	10](#_toc151682181)

[1.5 MODELO DE DISEÑO DEL SISTEMA.	20](#_toc151682182)

[1.5.1	DIAGRAMA DE CLASES DETALLADO.	20](#_toc151682183)

[1.5.1	DIAGRAMAS DE SECUENCIA.	21](#_toc151682184)

[1.5.2	DIAGRAMAS DE ENTIDAD-RELACION.	22](#_toc151682185)

[1.5.4 DIAGRAMAS DE COMPONENTES.	22](#_toc151682186)

[1.6 PRODUCTO DEL SOFTWARE.	23](#_toc151682187)

[**2**	**PRUEBAS DEL SOFTWARE**	26](#_toc151682188)

[**INTRODUCCIÓN**	26](#_toc151682189)

[**2.2 PLANIFICACIÓN DE LAS PRUEBAS**	27](#_toc151682190)

[**2.2.1. Objetivos de las pruebas**	27](#_toc151682191)

[**Objetivo General:**	27](#_toc151682192)

[**Objetivos Especificos:**	27](#_toc151682193)

[**2.2.2. Planificación de las Pruebas:**	27](#_toc151682194)

[**Objetivo General:**	27](#_toc151682195)

[**Objetivos Especificos:**	27](#_toc151682196)

[**Pruebas Unitarias: Objetivo General:**	27](#_toc151682197)

[**Objetivos Especificos:**	27](#_toc151682198)

[**Pruebas de Integracion: Objetivo General:**	28](#_toc151682199)

[**Objetivos Especificos:**	28](#_toc151682200)

[**2.2.1.**	**Módulos del sistema a probar**	29](#_toc151682201)

[**2.2.2.**	**Ambiente de pruebas**	29](#_toc151682202)

[Configuración base del Hardware	30](#_toc151682203)

[**2.2.3.**	**Responsables de las pruebas**	30](#_toc151682204)

[**2.3.**	**PRUEBAS UNITARIAS**	31](#_toc151682205)

[**2.3.1.**	**Análisis de pruebas**	31](#_toc151682206)

[2.4	PRUEBAS DE INTEGRACIÓN	39](#_toc151682207)

[2.3.5.	Diseño de caso de pruebas	45](#_toc151682208)

[2.3.5.1.	Tipo de prueba de sistema	46](#_toc151682209)

[3.	METRICAS DEL SOFTWARE	48](#_toc151682210)






1. # <a name="_toc149602608"></a><a name="_toc151682173"></a>**MODELOS DEL SISTEMA.**
   1. ## <a name="_toc151682174"></a>**IDENTIFICACION DEL PROBLEMA**

La Unidad Médica “Salud Cesar” se encarga de brindar atención médica general a pacientes con el propósito del bienestar social en el sector. Debido al éxito como institución que obtuvo de la población se evidenció un aumento de pacientes; debido a esto se evidenció una carencia al momento de realizar el registro de atención, agendar citas y derivación de pacientes. 

Al demostrar que el consultorio médico no posee un aplicativo de escritorio   que ayude en la gestión de control de dichos procesos, este conlleva a prolongados tiempos de espera para recibir asistencia médica, provocando una desorganización en la planificación y malestar en el público objetivo, dejando en mala reputación al consultorio médico. ciertas dificultades con, búsquedas manuales de información, tiempo de registros de forma manual, la pérdida o duplicación de la información de los pacientes, genera una imagen deficiente de la institución, así como reducción de ingresos al perder clientes. 

Por lo cual es menester contar con un sistema informático que permita la manipulación de los datos y procesos de forma eficiente y segura y que demuestra el profesionalismo del consultorio médico. Brindando así una mejor atención médica optimizando el tiempo y recursos con la finalidad de fomentar confianza hacia la Unidad Médica y poder hacer frente a sus competidores.

1. ## <a name="_toc151682175"></a>**DESCRIPCIÓN DETALLADA DEL SISTEMA O APLICACIÓN**

El software Salud Cesar presenta múltiples interfases diseñadas para simplificar la administración en entornos médicos, dirigidas a médicos, administradores y secretarios. Estas incluyen:

**Login (autenticación de usuarios):** Permite a los usuarios ya registrados verificar su información para resguardar la seguridad del sistema y evitar el acceso no deseado.

**Registro de Usuario:** Enfocada en médicos, administradores y secretarios, permite ingresar datos clave para acceder al sistema, con un énfasis en la seguridad mediante contraseñas.

**Gestión de Pacientes:** Dirigida a médicos, administradores y secretarios, facilita la modificación de datos y el registro de nuevos pacientes, ofreciendo herramientas para mantener actualizada la base de datos médica.

**Gestión de Usuarios**: Diseñada para administradores, permite la modificación de perfiles de usuarios garantizando un control preciso sobre el acceso al sistema.

**Filtrado de Citas y Ver Historial:** Ofrece a la admisión de citas, médicos y secretarios la capacidad de visualizar de manera eficiente las citas médicas mediante un sistema de filtrado, mejorando la planificación y gestión de citas.



# <a name="_toc149602610"></a><a name="_toc151682176"></a>**1.3 MODELO DE REQUERIMIENTOS.**
### <a name="_toc149602611"></a><a name="_toc151682177"></a>**1.3.1 REQUERIMIENTOS FUNCIONALES**

|<a name="_hlk151663972"></a>**N°**|**Requerimiento**|**Descripción**|
| :-: | :-: | :-: |
|**1**|Crear Usuario|Permite a administradores crear perfiles de usuarios, garantizando un control preciso sobre el acceso al sistema.|
|**2**|Modificar Usuario|Permite a administradores modificar perfiles de usuarios, asegurando la actualización de la información según sea necesario.|
|**3**|Eliminar Usuario|Permite a administradores eliminar perfiles de usuarios, manteniendo un control preciso sobre el acceso al sistema.|
|**4**|Consultar Usuarios|Permite a administradores consultar la información detallada de los perfiles de usuarios, brindando un panorama completo del sistema.|
|**5**|Autenticar usuario |<a name="_hlk151670393"></a>Permite a los usuarios ya registrados verificar su informacion con la BD para entrar al sistema.|
|**6**|Crear Cita|Permite a la admisión de citas, médicos y secretarios crear nuevas citas médicas en el sistema.|
|**7**|Modificar Cita|Permite a la admisión de citas, médicos y secretarios la modificación de detalles en las citas médicas existentes.|
|**8**|Eliminar Cita|Permite a la admisión de citas, médicos y secretarios eliminar citas médicas existentes en el sistema.|
|**9**|Consultar Citas|Permite a la admisión de citas, médicos y secretarios la consulta detallada de citas médicas, proporcionando información clave sobre cada cita en el sistema.|
|**10**|Crear Paciente|Permite a médicos, administradores y secretarios registrar nuevos pacientes en el sistema, proporcionando herramientas para mantener actualizada la base de datos médica.|
|**11**|Modificar Paciente|Facilita a médicos, administradores y secretarios la modificación de datos de pacientes existentes en el sistema.|
|**12**|Eliminar Paciente|Permite a médicos, administradores y secretarios la eliminación de registros de pacientes existentes en el sistema.|
|**13**|Consultar Pacientes|Permite a médicos, administradores y secretarios la consulta detallada de información sobre los pacientes en el sistema.|
|**14**|Filtrar Citas|Ofrece a la admisión de citas, médicos y secretarios la capacidad de filtrar eficientemente las citas médicas, mejorando la planificación y gestión de citas.|
|**15**|Acceder a la Base de Datos|El sistema debe ser capaz de acceder a la base de datos mediante solicitudes HTTP, garantizando la disponibilidad y eficiencia en la gestión de la información.|














Cuadro 1. Registro Usuario 

|Identificación del requerimiento: |RF01 |
| :- | :- |
|Nombre del Requerimiento: |Registro de usuarios. |
|Características: |Los usuarios deberán registrarse para acceder a cualquier función del sistema. |
|Descripción del requerimiento: |El sistema permitirá al usuario (,medico, secretario, administrador) registrarse. El usuario debe suministrar datos como: Cedula, Nombre, Apellidos, E-mail, Numero celular y dependiendo el tipo Usuario y contraseña Para la autenticación.|
||<p>Prioridad del requerimiento:  </p><p>Alta </p>|
||Fuente: Creación propia |



` `Cuadro 2. Gestión de pacientes

|Identificación del requerimiento: |RF02 |
| :- | :- |
|Nombre del Requerimiento: |Gestión de pacientes. |
|Características: |El sistema permitiría al usuario modificar datos que se encuentren en el sistema registrar pacientes en este |
|Descripción del requerimiento: |El administrador, médico o el secretario, podrán modificar los datos de los pacientes. |
||<p>Prioridad del requerimiento:  </p><p>Alta </p>|
||Fuente: Creación propia |


` `Cuadro 3. Gestión usuarios

|Identificación del requerimiento: |RF02 |
| :- | :- |
|Nombre del Requerimiento: |Gestión de Usuarios. |
|Características: |El sistema permitiría al usuario modificar datos que se encuentren en el sistema registrar pacientes en este |
|Descripción del requerimiento: |El administrador podrá modificar los datos de los usuarios |
||<p>Prioridad del requerimiento:  </p><p>Alta </p>|
||Fuente: Creación propia |












Cuadro 4. Historial de Citas.  

|Identificación del requerimiento: |RF05 ||
| :- | :- | :- |
|Nombre del Requerimiento: |historial de Citas. ||
|Características: |El sistema permitiría la admisioncita realizar un filtrado de las citas que se encuentren en el sistema. ||
|Descripción del requerimiento: |La admisioncita podrá ingresar al sistema y por medio de un filtrado podrá ver por fecha las citas médicas que se encuentren registradas en el sistema. ||
||<p>Prioridad del requerimiento:  </p><p>Alta </p>||
||Fuente: Creación propia ||
|<p></p><p></p><p></p><p><h3><a name="_toc151682178"></a>**1.3.2. REQUERIMIENTOS NO FUNCIONALES (RNF)**</h3>
## <a name="_toc149602613"></a><a name="_toc151682179"></a>**1.4 MODELO DE CASOS DE USO.**
## <a name="_toc149602614"></a><a name="_toc151682180"></a>**1.4.1 DIAGRAMAS DE CASO DE USO:**








<a name="_toc149602615"></a>		




# <a name="_toc151682181"></a>**1.4.2 DESCRIPCION DE CASO DE USO:**


|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Crear usuarios**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a los administradores crear perfiles de usuarios, garantizando un control preciso sobre el acceso al sistema.||
|**Actores:** Administrador, Base de datos,sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Los administradores deben tener autorización para crear perfiles de usuario||
|<p>**Flujo normal:** </p><p>`       `1.El administrador inicia sesión en el sistema. </p><p>2\. El administrador accede a la funcionalidad de creación de usuarios. 3. El sistema presenta un formulario para ingresar los datos del nuevo usuario. </p><p>4\. El administrador completa el formulario con la información requerida. </p><p>5\. El administrador envía la solicitud de creación de usuario. </p><p>6\. El sistema valida la información y crea el perfil de usuario en la base de datos. </p><p>7\. El sistema notifica al administrador que el usuario ha sido creado exitosamente.</p>||
|<p>**Flujo Alternativo:** </p><p>1. 1. El administrador inicia sesión en el sistema. </p><p>2\. El administrador accede a la funcionalidad de creación de usuarios. 3. El sistema presenta un formulario para ingresar los datos del nuevo usuario. </p><p>4\. El administrador completa el formulario con la información requerida.</p><p>5\. El administrador envía la solicitud de creación de usuario. </p><p>6\. El sistema valida la información pero detecta que algunos campos están incompletos. </p><p>7\. El sistema notifica al administrador sobre los campos incompletos y solicita corrección.</p><p>` `8. El administrador completa los campos faltantes y vuelve a enviar la solicitud. </p><p>9\. El sistema crea el perfil de usuario en la base de datos.</p><p>`      `10. El sistema notifica al administrador que el usuario ha sido creado exitosamente. </p>||
|**Postcondiciones:** El nuevo usuario puede ahora acceder al sistema con las credenciales proporcionadas.||

|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Modificar Usuario**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a los administradores modificar perfiles de usuarios, asegurando la actualización de la información según sea necesario.||
|**Actores:** administrador, Base de datos,sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Los administradores deben tener autorización para modificar perfiles de usuario.||
|<p>**Flujo normal:** </p><p>1. ` `Un administrador inicia sesión en el sistema.</p><p>2. ` `El administrador accede a la funcionalidad de modificación de usuarios. </p><p>3. ` `El sistema presenta un formulario con los datos actuales del usuario.</p><p>4. `  `El administrador realiza las modificaciones necesarias en el formulario.</p><p>5. ` `El administrador envía la solicitud de modificación de usuario.</p><p>6. `  `El sistema valida la información y actualiza el perfil de usuario en la base de datos.</p><p>7. ` `7. El sistema notifica al administrador que la modificación ha sido realizada exitosamente.</p>||
|<p>**Flujo Alternativo:** </p><p>2. ` `Un administrador inicia sesión en el sistema. </p><p>3. El administrador accede a la funcionalidad de modificación de usuarios. </p><p>4. ` `El sistema presenta un formulario con los datos actuales del usuario. </p><p>4\. El administrador realiza las modificaciones necesarias en el formulario. </p><p>5\. El administrador envía la solicitud de modificación de usuario.</p><p>`      `6. El sistema valida la información pero detecta que algunos campos         están incorrectos. </p><p>7\. El sistema notifica al administrador sobre los campos incorrectos y solicita corrección.</p><p>` `8. El administrador corrige los campos y vuelve a enviar la solicitud. 9. El sistema actualiza el perfil de usuario en la base de datos.</p><p>` `10. El sistema notifica al administrador que la modificación ha sido realizada exitosamente.</p><p></p>||
|**Postcondiciones:** El perfil del usuario se ha actualizado en la base de datos, reflejando las modificaciones realizadas por el administrador.||



|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Eliminar Usuario**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a los administradores eliminar perfiles de usuarios, garantizando un control preciso sobre la gestión de cuentas en el sistema.||
|**Actores:** administrador, Base de datos,sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Los administradores deben tener autorización para modificar perfiles de usuario.||
|<p>**Flujo normal:** </p><p>1\. El administrador inicia sesión en el sistema. </p><p>2\. El administrador accede a la funcionalidad de eliminación de usuarios. 3. El sistema presenta una lista de usuarios existentes. </p><p>4\. El administrador selecciona el usuario a eliminar.</p><p>` `5. El administrador confirma la solicitud de eliminación.</p><p>` `6. El sistema elimina el perfil de usuario de la base de datos. </p><p>7\. El sistema notifica al administrador que el usuario ha sido eliminado exitosamente.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El administrador inicia sesión en el sistema. </p><p>2\. El administrador accede a la funcionalidad de eliminación de usuarios. 3. El sistema presenta una lista de usuarios existentes.</p><p>` `4. El administrador selecciona el usuario a eliminar. </p><p>5\. El administrador cancela la solicitud de eliminación. </p><p>6\. El sistema mantiene el perfil de usuario en la base de datos</p><p>. 7. El sistema notifica al administrador que la solicitud de eliminación ha sido cancelada.</p>||
|**Postcondiciones:** El perfil del usuario ha sido eliminado de la base de datos.||











|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Consultar Usuario**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a los administradores consultar la información de perfiles de usuarios, brindando acceso a detalles relevantes para la gestión del sistema..||
|**Actores:** Administrador, Base de datos, Sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Los administradores deben tener autorización para consultar perfiles de usuario.||
|<p>**Flujo normal:** </p><p>1\. El administrador inicia sesión en el sistema.</p><p>` `2. El administrador accede a la funcionalidad de consulta de usuarios. </p><p>3\. El sistema presenta una lista de usuarios existentes</p><p>4\. El administrador selecciona el usuario a consultar. </p><p>5\. El sistema muestra los detalles del perfil de usuario seleccionado.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El administrador inicia sesión en el sistema. </p><p>2\. El administrador accede a la funcionalidad de consulta de usuarios.</p><p>` `3. El sistema presenta una lista de usuarios existentes.</p><p>` `4. El administrador realiza una búsqueda específica por criterios como nombre, ID, u otros. </p><p>5\. El sistema muestra los resultados de la búsqueda y permite al administrador seleccionar un usuario.</p><p>` `6. El sistema muestra los detalles del perfil de usuario seleccionado.</p>||
|**Postcondiciones:** La información del perfil del usuario ha sido consultada por el administrador.||

















|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Autenticar usuario**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite al sistema autenticar a los usuarios, validando sus credenciales para permitir o denegar el acceso al sistema.||
|**Actores:** usuario, Base de datos, Sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Los administradores deben tener autorización para consultar perfiles de usuario.||
|<p>**Flujo normal:** </p><p>1\. El usuario ingresa su nombre de usuario y contraseña en el formulario de inicio de sesión. </p><p>2\. El sistema valida las credenciales en la base de datos.</p><p>` `3. Si las credenciales son válidas, el sistema permite el acceso y autentica al usuario.</p><p>` `4. El sistema redirige al usuario a la interfaz principal del sistema.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El usuario ingresa su nombre de usuario y contraseña en el formulario de inicio de sesión. </p><p>2\. El sistema valida las credenciales en la base de datos.</p><p>` `3. Si las credenciales son inválidas, el sistema muestra un mensaje de error y niega el acceso al usuario. </p><p>4\. El sistema permite al usuario intentar nuevamente ingresando las credenciales correctas.</p>||
|**Postcondiciones:** El usuario ha sido autenticado y puede acceder a las funcionalidades del sistema.||
















|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Crear cita**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a médicos y secretarios crear citas médicas para pacientes, facilitando la gestión de horarios y la planificación de consultas..||
|**Actores:** Médico, secretario, Administrador Base de datos, Sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Médicos y secretarios deben tener autorización para programar citas..||
|<p>**Flujo normal:** </p><p>1\. El médico o secretario inicia sesión en el sistema.</p><p>` `2. El usuario accede a la funcionalidad de creación de citas. </p><p>3\. El sistema presenta un formulario para ingresar los detalles de la cita (paciente, fecha, hora, etc.). </p><p>4\. El médico o secretario completa el formulario con la información requerida. </p><p>5\. El usuario envía la solicitud de creación de cita</p><p>` `6. El sistema valida la información y registra la cita en la base de datos. 7. El sistema notifica al médico o secretario que la cita ha sido creada exitosamente.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El médico o secretario inicia sesión en el sistema. </p><p>2\. El usuario accede a la funcionalidad de creación de citas. </p><p>3\. El sistema presenta un formulario para ingresar los detalles de la cita (paciente, fecha, hora, etc.). </p><p>4\. El médico o secretario completa el formulario con la información requerida. </p><p>5\. El usuario cancela la solicitud de creación de cita. </p><p>6\. El sistema cancela el proceso y no registra la cita en la base de datos. 7. El sistema notifica al médico o secretario que la solicitud de creación de cita ha sido cancelada.</p>||
|**Postcondiciones:** La cita médica ha sido creada y registrada en la base de datos.||









|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Modificar  cita**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a médicos y secretarios crear citas médicas para pacientes, facilitando la gestión de horarios y la planificación de consultas.||
|**Actores:** Médico, secretario, Administrador Base de datos, Sistema||
|**Precondiciones:** Permite a médicos y secretarios modificar detalles de citas médicas existentes, brindando flexibilidad en la gestión de horarios y la actualización de información relevante.||
|<p>**Flujo normal:** </p><p>1\. El médico o secretario inicia sesión en el sistema. </p><p>2\. El usuario accede a la funcionalidad de modificación de citas. </p><p>3\. El sistema presenta una lista de citas programadas.</p><p>` `4. El médico o secretario selecciona la cita a modificar. </p><p>5\. El sistema muestra un formulario prellenado con los detalles actuales de la cita. </p><p>6\. El médico o secretario realiza las modificaciones necesarias.</p><p>` `7. El usuario envía la solicitud de modificación de cita.</p><p>` `8. El sistema valida la información y actualiza los detalles de la cita en la base de datos. </p><p>9\. El sistema notifica al médico o secretario que la cita ha sido modificada exitosamente.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El médico o secretario inicia sesión en el sistema. </p><p>2\. El usuario accede a la funcionalidad de modificación de citas.</p><p>` `3. El sistema presenta una lista de citas programadas. </p><p>4\. El médico o secretario selecciona la cita a modificar.</p><p>` `5. El médico o secretario cancela la solicitud de modificación de cita</p><p>6\. El sistema mantiene los detalles de la cita sin cambios. 7. El sistema notifica al médico o secretario que la solicitud de modificación de cita ha sido cancelada.</p>||
|**Postcondiciones:** Los detalles de la cita médica han sido actualizados en la base de datos.||










|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Eliminar Cita**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a médicos y secretarios eliminar citas médicas programadas, facilitando la gestión de horarios y la actualización de la agenda.||
|**Actores: ,**Médico, secretario, Administrador Base de datos, Sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Médicos y secretarios deben tener autorización para eliminar citas.||
|<p>**Flujo normal:** </p><p>1\. El médico o secretario inicia sesión en el sistema. </p><p>2\. El usuario accede a la funcionalidad de eliminación de citas.</p><p>` `3. El sistema presenta una lista de citas programadas. </p><p>4\. El médico o secretario selecciona la cita a eliminar. </p><p>5\. El usuario confirma la solicitud de eliminación de cita. </p><p>6\. El sistema elimina la cita de la base de datos.</p><p>` `7. El sistema notifica al médico o secretario que la cita ha sido eliminada exitosamente.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El médico o secretario inicia sesión en el sistema.</p><p>` `2. El usuario accede a la funcionalidad de eliminación de citas.</p><p>` `3. El sistema presenta una lista de citas programadas. </p><p>4\. El médico o secretario selecciona la cita a eliminar. </p><p>5\. El usuario cancela la solicitud de eliminación de cita.</p><p>` `6. El sistema mantiene la cita en la base de datos sin cambios.</p><p>` `7. El sistema notifica al médico o secretario que la solicitud de eliminación de cita ha sido cancelada.</p>||
|<p>**Postcondiciones:** </p><p>La cita médica ha sido eliminada de la base de datos.</p><p></p>||













|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Consultar Cita**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a médicos, secretarios y personal autorizado consultar información detallada sobre citas médicas programadas, brindando acceso a detalles relevantes para la gestión eficiente de consultas.||
|**Actores:** Médico, secretario, Administrador Base de datos, Sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Médicos y secretarios deben tener autorización para eliminar citas.||
|<p>**Flujo normal:** </p><p>1\. El médico o secretario inicia sesión en el sistema.</p><p>` `2. El usuario accede a la funcionalidad de consulta de citas. </p><p>3\. El sistema presenta una lista de citas programadas. </p><p>4\. El médico o secretario selecciona la cita a consultar. </p><p>5\. El sistema muestra detalles completos de la cita, incluyendo información del paciente, fecha, hora y otros detalles relevantes.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El médico o secretario inicia sesión en el sistema. </p><p>2\. El usuario accede a la funcionalidad de consulta de citas. </p><p>3\. El sistema presenta una lista de citas programadas.</p><p>` `4. El médico o secretario realiza una búsqueda específica por criterios como nombre del paciente, fecha, u otros.</p><p>` `5. El sistema muestra los resultados de la búsqueda y permite al usuario seleccionar una cita.</p><p>` `6. El sistema muestra detalles completos de la cita seleccionada.</p>||
|<p>**Postcondiciones:** </p><p>La información detallada de la cita ha sido consultada por el médico o secretario.</p>||














|**Salud cesar**||
| :-: | :- |
|**Nombre:**|**Crear Paciente**|
|**Autor:**|Diego Armando Maza Churio|
|**Fecha:**|1/Oct/2023|
|**Descripción:** Permite a médicos, secretarios y personal autorizado registrar nuevos pacientes en el sistema, facilitando la administración de la base de datos médica.||
|**Actores:** Médico, secretario, Administrador Base de datos, Sistema||
|**Precondiciones:** El sistema debe estar en un estado operativo y configuración adecuada. Personal autorizado debe tener permisos para crear nuevos pacientes.||
|<p>**Flujo normal:** </p><p>1\. El médico o secretario inicia sesión en el sistema. </p><p>2\. El usuario accede a la funcionalidad de creación de pacientes. 3. El sistema presenta un formulario para ingresar los detalles del nuevo paciente (nombre, fecha de nacimiento, historial médico, etc.).</p><p>` `4. El médico o secretario completa el formulario con la información requerida. </p><p>5\. El usuario envía la solicitud de creación de paciente. </p><p>6\. El sistema valida la información y registra al nuevo paciente en la base de datos. </p><p>7\. El sistema notifica al médico o secretario que el paciente ha sido creado exitosamente.</p>||
|<p>**Flujo Alternativo:** </p><p>1\. El médico o secretario inicia sesión en el sistema. </p><p>2\. El usuario accede a la funcionalidad de creación de pacientes. </p><p>3\. El sistema presenta un formulario para ingresar los detalles del nuevo paciente (nombre, fecha de nacimiento, historial médico, etc.). </p><p>4\. El médico o secretario completa el formulario con la información requerida. </p><p>5\. El usuario cancela la solicitud de creación de paciente. </p><p>6\. El sistema cancela el proceso y no registra al nuevo paciente en la base de datos. </p><p>7\. El sistema notifica al médico o secretario que la solicitud de creación de paciente ha sido cancelada.</p>||
|<p>**Postcondiciones:** </p><p>El nuevo paciente ha sido registrado en la base de datos.</p>||







## <a name="_toc149602616"></a><a name="_toc151682182"></a>**1.5 MODELO DE DISEÑO DEL SISTEMA.**
1. ### <a name="_toc149602617"></a><a name="_toc151682183"></a>**DIAGRAMA DE CLASES DETALLADO.**

2. ### <a name="_toc149602618"></a><a name="_toc151682184"></a>**DIAGRAMAS DE SECUENCIA.**

3. ### <a name="_toc149602619"></a><a name="_toc151682185"></a>**DIAGRAMAS DE ENTIDAD-RELACION.**

### <a name="_toc149602620"></a><a name="_toc151682186"></a>**1.5.4 DIAGRAMAS DE COMPONENTES.**

##
## <a name="_toc149602621"></a><a name="_toc151682187"></a>**1.6 PRODUCTO DEL SOFTWARE.**
[**https://github.com/FUKEN7/Odontologia_Software-II.git**](https://github.com/FUKEN7/Odontologia_Software-II.git)

 

![ref1]

![ref2]
































1. <a name="_toc151682188"></a>**PRUEBAS DEL SOFTWARE**

<a name="_toc3806"></a><a name="_toc149602622"></a><a name="_toc151682189"></a>**INTRODUCCIÓN**

<a name="_toc3807"></a>Las evaluaciones realizadas en el software con el fin de demostrar su calidad y confiabilidad desempeñan un papel crucial en la identificación y corrección de posibles errores y defectos. El propósito principal de estas pruebas es garantizar que el software cumpla con los requisitos y especificaciones establecidos por el cliente. En este contexto, se llevan a cabo algunas categorías de pruebas esenciales como lo son: pruebas unitarias e incluso las pruebas de integración.

Las pruebas unitarias se centran en la verificación de la funcionalidad de cada componente individual de código del software. En general, el equipo de desarrollo asume la responsabilidad de realizar estas pruebas, dedicando sus esfuerzos a la identificación de posibles errores en el código. Una vez confirmado que cada unidad de código funciona correctamente, se avanza hacia las pruebas de integración. Estas pruebas buscan asegurar el adecuado desempeño de diferentes unidades de código cuando se combinan, con el objetivo de detectar posibles fallos en la integración de diversas partes del software, como la comunicación entre módulos y la transferencia de datos entre ellos.

Posteriormente, se llevan a cabo pruebas de en el sistema para garantizar el correcto funcionamiento del software en su totalidad y su conformidad con las especificaciones y requisitos del cliente. Estas pruebas suelen ser realizadas por un equipo de pruebas independiente, enfocándose en detectar errores en el rendimiento del software en diversas situaciones, así como en la usabilidad y satisfacción del usuario. Finalmente, se ejecutan las pruebas de aceptación, que constituyen un tipo específico de prueba de software diseñado para verificar que el sistema cumpla con los requisitos del usuario, asegurando su aceptabilidad.

















`	 `**<a name="_toc149602623"></a><a name="_toc151682190"></a>2.2 PLANIFICACIÓN DE LAS PRUEBAS** 

<a name="_toc151630046"></a><a name="_toc151630047"></a><a name="_toc151682191"></a>**2.2.1. Objetivos de las pruebas**

<a name="_toc151682192"></a>**Objetivo General:**

- Garantizar la excel<a name="_toc151630048"></a>encia y fiabilidad del software.

<a name="_toc151682193"></a>**Objetivos Especificos:**

- Identificar y corregir defectos y errores en el software.
- Validar que el software cumple con los requisitos definidos.
- Garantizar que el software funcione de manera adecuada y eficiente.
- Evaluar la seguridad, usabilidad y rendimiento del software. 

<a name="_toc151682194"></a>**2.2.2. Planificación de las Pruebas:**

<a name="_toc151682195"></a>**Objetivo General:**

- Establecer una estrategia eficiente para la realización de pruebas de software.

<a name="_toc151682196"></a>**Objetivos Especificos:**

- Definir los objetivos y alcance de las pruebas.
- Asignar recursos y definir responsabilidades.
- Establecer un calendario y un plan de ejecución.
- Identificar los riesgos y desarrollar estrategias de mitigación.



<a name="_toc151682197"></a>**Pruebas Unitarias:\
Objetivo General:**

- Verificar que los componentes individuales del software funcionen correctamente.

<a name="_toc151682198"></a>**Objetivos Especificos:**

- Identificar y corregir errores en módulos o funciones específicas.
- Validar que los componentes cumplan con sus especificaciones.
- Asegurar que las unidades de código sean coherentes y confiables.

<a name="_toc151682199"></a>**Pruebas de Integracion:\
Objetivo General:**

- Evaluar la interacción y la integración adecuada de los módulos o componentes del software.

<a name="_toc151682200"></a>**Objetivos Especificos:**

- Verifique que los módulos funcionen juntos sin conflictos.
- Validar que los datos se transmitan correctamente entre los componentes.
- Identificar y resolver problemas de comunicación entre los módulos.

.2.2 Alcance de las pruebas

“El presente documento lista las distintas pruebas a ser ejecutadas durante el proceso  de prueba del sistema que permitirán asegurar el cumplimiento de los objetivos y los requerimientos del software, la forma en la que se ejecutarán, los criterios de aceptación, así como la forma y medios para registrar los resultados de la ejecución de pruebas.

<table><tr><th colspan="3"><b>Niveles, tipos y métodos de prueba</b></th></tr>
<tr><td colspan="1"><b>Niveles de pruebas</b></td><td colspan="1"><b>Modelos/estrategias/ tipos</b></td><td colspan="1"><b>Herramientas</b></td></tr>
<tr><td colspan="1" rowspan="4">Pruebas unitarias</td><td colspan="1">Prueba de caja negra</td><td colspan="1" rowspan="4">No se usaron herramientas, se utilizaron los procedimientos vistos en clase.</td></tr>
<tr><td colspan="1">Pruebas de caja blanca</td></tr>
<tr><td colspan="1">Análisis de valores límite</td></tr>
<tr><td colspan="1"><p>Pruebas de Particiones de</p><p>Equivalencia</p></td></tr>
<tr><td colspan="1" rowspan="2">Pruebas de integración</td><td colspan="1">Incremental ascendente</td><td colspan="1" rowspan="2"><p>Katalon</p><p></p></td></tr>
<tr><td colspan="1">Incremental descendente</td></tr>
<tr><td colspan="1" rowspan="4"><p>Pruebas de sistemas</p><p></p></td><td colspan="1">Pruebas de funcionalidad</td><td colspan="1"></td></tr>
<tr><td colspan="1">Pruebas de rendimiento</td><td colspan="1"></td></tr>
<tr><td colspan="1">Pruebas de usabilidad</td><td colspan="1"></td></tr>
<tr><td colspan="1"></td><td colspan="1"></td></tr>
<tr><td colspan="1">Pruebas de aceptación</td><td colspan="1"><p></p><p>Moderated Usability Testing</p><p>Unmoderated Usability Testing</p><p></p></td><td colspan="1"></td></tr>
</table>



1. <a name="_toc149602628"></a><a name="_toc151682201"></a>**Módulos del sistema a probar<a name="_toc3811"></a>** 

|**Nombre de la aplicación a probar**|OdontoCesar|
| :-: | :-: |
|**Módulos a ser probados**|**Objetivos de las pruebas**|
|Login (Autenticacion)|Validar que los datos ingresados por el usuario sean los correctos para ingresar.|
|Usuario/(Persona)|Validar que los datos ingresados por el usuario cumplan con los requerimientos propuestos|
|Paciente|Validar que los datos ingresados por el usuario cumplan con los requerimientos propuestos|
|Cita|Verificar que no haya incongruencias a la hora de apartar cita.|

1. ` `**<a name="_toc149602629"></a><a name="_toc151682202"></a>Ambiente de pruebas**
   1. <a name="_toc147686306"></a>Hardware

Programa Visual studio 2022

|Dispositivo|Procesador|DD|RAM|Aplicación a instalar|
| :-: | :-: | :-: | :-: | :-: |
|<p>DESKTOP-1EJLUN7</p><p>Windows 10 Pro</p><p>Windows Feature Experience Pack 1000.19044.1000.0</p>|Intel(R) Core(TM) i5-6200U CPU @ 2.30GHz   2.40 GHz.|<p>Al menos 20 GB</p><p>de espacio libre en el disco duro</p>|4,00 GB (3,89 GB utilizables)|<p>Se requiere .NET Framework 4.5.2 o posterior. Visual Studio 2019 instalará y utilizará .NET</p><p>Framework 4.8 si no está instalado. Para poder correr el programa sin problema toca instalar</p>|

<a name="_toc147686307"></a>Base de dato en SQL SERVER 2019

|Equipo|Procesador|DD|RAM|Aplicación a instalar|
| :- | :- | :- | :- | :- |
|<p>Windows Server 2019</p><p>Standard o Datacenter</p><p>Windows Server 2016</p><p>Standard o Datacenter</p><p>Windows 10 Pro o</p><p>Enterprise</p>|Procesador x64 de 1.4 GHz o más rápido|<p>6 GB de espacio libre en el disco duro para la instalación básica. Para una</p><p>instalación completa, se requiere más espacio en disco adicional.</p>|<p>2 GB de RAM</p><p>como mínimo; 4 GB o más</p><p>recomendado.</p>|Se requiere .NET Framework 4.6.2 o posterior.|


<a name="_toc151630052"></a><a name="_toc151682203"></a>Configuración base del Hardware

|**Equipo**|**Especificaciones técnicas**|
| :-: | :-: |
|Acer Nitro 5|<p>Procesador: Intel® Core™ i5 de 10ma Generación</p><p>Memoria RAM: 8 Gb 3600 MHZ</p><p>Windows: 11 PRO</p>|
|Computadora de escritorio|<p>Procesador: AMD Ryzen 5 5600 G</p><p>Memoria RAM: 16 Gb 3600 MHZ</p><p>Windows: 11 Pro</p>|

<a name="_toc151630053"></a>Software para el ambiente de prueba

|**Software**|**Versión**|**Plataforma**|
| :-: | :-: | :-: |
|Visual Studio community|2022|escritorio|
|windows server|2019|escritorio|

1. <a name="_toc149602630"></a><a name="_toc151682204"></a>**Responsables de las pruebas**

|**ROL**|**ACTIVIDADES**|
| - | - |
|Diseñador y Analista: Harold Britto|Diseñador de la aplicativo, en conjunto analista de pruebas de desarrollo|
|Diseñador y Analista: Diego Maza |Diseñador y analista de pruebas de sistemas|

1. Software

Visual Studio 2022 representa un ambiente de desarrollo completo, destinado principalmente a la creación de aplicaciones de software. No obstante, en lo que respecta a la evaluación y verificación de software, Visual Studio 2022 proporciona un conjunto integral de recursos y funcionalidades incorporadas que facilitan a los equipos de pruebas llevar a cabo sus evaluaciones de manera efectiva.

Entre las utilidades de evaluación integradas en Visual Studio 2022, se destacan:

- Microsoft Test Manager (MTM)
- Pruebas unitarias y de integración
- Pruebas de carga y rendimiento
- Pruebas de interfaz de usuario (UI)

Adicionalmente, Visual Studio 2022 ofrece compatibilidad con diversos marcos de evaluación de terceros, tales como NUnit, xUnit y MSTest. 	 

2. <a name="_toc3812"></a><a name="_toc149602631"></a><a name="_toc151682205"></a>**PRUEBAS UNITARIAS**
   1. ` `**<a name="_toc149602632"></a><a name="_toc151682206"></a>Análisis de pruebas** 
2. Clases de equivalencia Login: 

3. **Clases de equivalencias por modulo:**

|CONDICIÓN DE ENTRADA|CLASE VÁLIDA|CLASE INVÁLIDA|
| :-: | :-: | :-: |
|<p>Usuario, campo alfanumérico entre 5 y 20 caracteres numéricos.</p><p></p>|5 <= Caracteres <= 20|<p>Carácter < 5</p><p>Carácter > 20</p><p>Carácter = null</p>|
|<p>Contraseña, campo alfanumérico entre 5 y 20 caracteres numéricos</p><p></p>|5 <= Caracteres <= 20|<p>Carácter < 5</p><p>Carácter > 20</p><p>Carácter = null</p>|

1. **Casos de pruebas:**

|DATO ENTRADA|VALOR|ESCENARIO|
| :-: | :-: | :-: |
|Usuario|Diegomaza|correcto|
|Usuario|dieg|incorrecto|
|Contraseña|DAMC\_4223010|correcto|
|Contraseña|1234|incorrecto|




1. **Valores Límites:**

<table><tr><th colspan="1">DATO DE ENTRADA</th><th colspan="1" valign="top">VALOR</th></tr>
<tr><td colspan="1" rowspan="4" valign="top"><p>USUARIO: entre 5 y 20 caracteres</p><p></p></td><td colspan="1" valign="top">Leonardo maza felipe</td></tr>
<tr><td colspan="1" valign="top">diego</td></tr>
<tr><td colspan="1" valign="top">Leonardo andres felipe</td></tr>
<tr><td colspan="1" valign="top">leon</td></tr>
<tr><td colspan="1" rowspan="4" valign="top"><p>Contraseña: entre 5 y 20 caracteres</p><p></p></td><td colspan="1" valign="top">DAMC1234567891011124</td></tr>
<tr><td colspan="1" valign="top">DAMC3</td></tr>
<tr><td colspan="1" valign="top">DAMC12345678910111243</td></tr>
<tr><td colspan="1" valign="top">DAMC</td></tr>
</table>

1. **Pruebas del camino básico:**

|FÓRMULA|RESULTADO|
| :- | :- |
|V(g) = nodos – vértices + 2|V(g) = 5 – 5 + 2 = 2|
|V(g) = número de regiones cerradas + inicio y fin (1)|V(g) = 1 + 1 = 2|
|V(g) = número de nodos de condición + 1|V(g) = 1 + 1 = 2|

|Caminos ||
| :- | :- |
|Camino 1|1-2-4-1|
|Camino 2|1-2-3-5|



1. **Clases de equivalencia Registro de pacientes:** 

![ref3]

1. **Clases de equivalencias**

|**CONDICIÓN DE ENTRADA**|**CLASE VÁLIDA**|**CLASE INVÁLIDA** |
| :-: | :-: | :-: |
|<p>**idpaciente**</p><p>que es un campo de 10 caracteres.</p><p>(obligatorio)</p>|1. idpaciente=10|<p>2. idpaciente<10</p><p>3. idpaciente>10</p><p>4. Null</p>|
|<p>**Nombre**</p><p>campo mínimo de 2 caracteres y máximo 30 caracteres.</p>|5. 2<=nombre<=30|<p>6. Nombre<2</p><p>7. Nombre>30</p><p>8. numeros </p><p>9. caracteres especiales</p>|
|<p>**Telefono**</p><p>que es un campo de 10 caracteres.</p>|10. Telefono=10|<p>11. Telefono<10</p><p>12. ` `Telefono>10</p>|
|<p>**Correo**</p><p>campo cadena entre 5 y 100</p>|13. <= dirección <= 50 |<p>14. correo < 5</p><p>15. correo > 50</p>|
|<p>**Fecha**</p><p>es un campo que indica la fecha en el que se registró el paciente.</p>|16. Entrada tipo date o fecha (dd/mm//aaa)|<p></p><p>17. No es formato fecha</p>|
|<p>**Enfermedad**</p><p>campo mínimo de 2 caracteres  y máximo 300 caracteres. (Obligatorio)</p>|18. 2<=enfermedad<=300|<p>19. enfermedad<2</p><p>20. enfermedad>200</p><p>21. null</p>|
|<p>**Recomendaciones** campo mínimo de 2 caracteres y máximo 300 caracteres.</p><p>(Obligatorio)</p>|22. 2<=recomendaciones<=300|<p>23. recomendaciones<2</p><p>24. recomendaciones>300</p><p>25. null</p>|

1. Casos de pruebas.

|**Dato de entrada**|**Valor**|**Escenario**|
| :-: | :-: | :-: |
|**idpaciente**|<p>- 1234567890</p><p>- 1066379725</p>|**CORRECTO.**|
|**idpaciente**|<p>- 106</p><p>- 107748083623</p>|**INCORRECTO.**|
|**Nombre**|<p>- Harold Britto</p><p>- Diego Maza</p>|**CORRECTO.**|
|**Nombre**|<p>- L</p><p>- 523</p><p>- L@\*$</p><p>- Teodora Vicenta de la Purísima Concepción de la Inmaculada Trinidad Villavicencio, Duquesa de Oraverás, Marquesa del Jujuy y niña de la Condesa</p>|**INCORRECTO.**|
|**Teléfono**|<p>- 3178884485</p><p>- 319 3120156</p>|**CORRECTO.**|
|**Teléfono**|<p>- 319312015700</p><p>- 31788</p>|**INCORRECTO.**|
|**Correo**|<p>- <harold@gmail.com></p><p>- Diego@gmail.com</p>|**CORRECTO.**|
|**Correo**|<p>- a@</p><p>- 12345…….102@gmail</p>|**INCORRECTO.**|
|**Fecha**|- 23/08/2023|**CORRECTO.**|
|**Fecha**|<p>- 23 de agosto del 2023</p><p>- 08/23/2023</p>|**INCORRECTO.**|
|**Enfermedad**|<p>- Gripa</p><p>- Escoliosis</p><p>- Pneumonoultramicroscopicsilicovolcanoconiosis </p>|**CORRECTO.**|
|**Enfermedad**|<p>- Gr</p><p>- Diarr………….304</p>|**INCORRECTO.**|
|**Recomendaciones**|- El paciente deberá tomar \*\*\*\*\*\*\*\* en pastillas de \*\*\*ml, deberá descansar y estar en reposo durante 1 semana.|**CORRECTO.**|
|**Recomendaciones**|<p>- El….</p><p>- El aciente deberá \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*302…</p>|**INCORRECTO.**|










1. Valores limites

<table><tr><th colspan="1"><b>CONDICIÓN DE ENTRADA</b></th><th colspan="1"><b>DESCRIPCIÓN DE LOS CASOS</b></th></tr>
<tr><td colspan="1" rowspan="4"><p><b>Nombre</b></p><p>campo mínimo de 2 caracteres y máximo 30 caracteres.</p></td><td colspan="1">Diego…30</td></tr>
<tr><td colspan="1">Di</td></tr>
<tr><td colspan="1">Diego…31</td></tr>
<tr><td colspan="1">D</td></tr>
<tr><td colspan="1" rowspan="4"><p><b>Correo</b></p><p>campo cadena entre 5 y 100</p></td><td colspan="1">Luis@…50</td></tr>
<tr><td colspan="1">Luis@</td></tr>
<tr><td colspan="1">Luis@…49</td></tr>
<tr><td colspan="1">Luis</td></tr>
<tr><td colspan="1" rowspan="4"><p><b>Enfermedad</b></p><p>campo mínimo de 2 caracteres y máximo 300 caracteres.</p><p>(Obligatorio)</p></td><td colspan="1">Gripa…300</td></tr>
<tr><td colspan="1">Gr</td></tr>
<tr><td colspan="1">Gripa…301</td></tr>
<tr><td colspan="1">G</td></tr>
<tr><td colspan="1" rowspan="4"><p><b>Recomendaciones</b> campo mínimo de 2 caracteres y máximo 300 caracteres.</p><p>(Obligatorio)</p></td><td colspan="1">El paciente…300</td></tr>
<tr><td colspan="1">EL</td></tr>
<tr><td colspan="1">El paciente…301</td></tr>
<tr><td colspan="1">E</td></tr>
</table>














1. Clases de equivalencia Registro de Persona: 

![ref4]

1. Clases de equivalencias

|**CONDICIÓN DE ENTRADA**|**CLASE VÁLIDA**|**CLASE INVÁLIDA** |
| :-: | :-: | :-: |
|<p>**idpersona** </p><p>que es un campo de 10 caracteres.</p><p>(obligatorio)</p>|1. idpersona=10|<p>1. idpersona<10</p><p>2. idpersona>10</p><p>3. Null</p>|
|<p>**Nombre**</p><p>campo mínimo de 3 caracteres  y máximo 30 caracteres.</p>|4. 3<=nombre<=30|<p>5. Nombre<3</p><p>6. Nombre>30</p><p>7. numeros </p><p>8. caracteres especiales</p>|
|<p>**Telefono**</p><p>que es un campo de 10 caracteres.</p>|9. Telefono=10|<p>10. Telefono<10</p><p>11. ` `Telefono>10</p>|
|<p>**Correo**</p><p>campo cadena entre 10 y 100</p>|<p>12. 10<= Correo <= 100</p><p></p>|<p>13. correo < 10</p><p>14. correo > 100</p>|



1. Casos de pruebas.

|**Dato de entrada**|**Valor**|**Escenario**|
| :-: | :-: | :-: |
|**idpersona**|<p>- 1065571655</p><p>- 1066346725</p>|**CORRECTO.**|
|**idpersona**|<p>- 10333</p><p>- 10323131212312</p>|**INCORRECTO.**|
|**Nombre**|<p>- Harold Britto</p><p>- Diego Maza</p>|**CORRECTO.**|
|**Nombre**|<p>- Ñ</p><p>- 52323</p><p>- ¨\*\*\*\_Ñ</p><p>- Camilo Angarita…..33</p>|**INCORRECTO.**|
|**Teléfono**|<p>- 3177543221</p><p>- 3193120157</p>|**CORRECTO.**|
|**Teléfono**|<p>- 31933123121</p><p>- 321234</p>|**INCORRECTO.**|
|**Correo**|<p>- [diego@gmail.com](mailto:harold@gmail.com)</p><p>- andres@gmail.com</p><p></p>|**CORRECTO.**|
|**Correo**|<p>- d@</p><p>- 3312…….104@gmail</p>|**INCORRECTO.**|

1. Valores limites

<table><tr><th colspan="1"><b>CONDICIÓN DE ENTRADA</b></th><th colspan="1"><b>DESCRIPCIÓN DE LOS CASOS</b></th></tr>
<tr><td colspan="1" rowspan="4" valign="top"><p><b>Nombre</b></p><p>campo mínimo de 2 caracteres y máximo 30 caracteres.</p></td><td colspan="1">Diego…30</td></tr>
<tr><td colspan="1">Di</td></tr>
<tr><td colspan="1">Diego…31</td></tr>
<tr><td colspan="1">D</td></tr>
<tr><td colspan="1" rowspan="4" valign="top"><p><b>Correo</b></p><p>campo cadena entre 5 y 100</p></td><td colspan="1" valign="top">Luis@…50</td></tr>
<tr><td colspan="1" valign="top">Luis@</td></tr>
<tr><td colspan="1" valign="top">Luis@…49</td></tr>
<tr><td colspan="1" valign="top">Luis</td></tr>
</table>

1. Diseño de casos de pruebas  
1. Pruebas del camino básico:



2. !Ejecución de las pruebas






1. Evaluación de las pruebas
# <a name="_toc151630059"></a><a name="_toc151682207"></a>**2.4	PRUEBAS DE INTEGRACIÓN**







|**PRUEBAS ASCENDENTES**||
| :-: | :- |
|**UNITARIAS**|F – G – H|
|**INTEGRACIÓN**|<p>( C-F ), ( D-G ), ( E-H ),</p><p>( B-C ), ( B-D ), ( B-E ),</p><p>( A-B ).</p>|
|**PRUEBAS DESCENDENTES**||
|**PROFUNDIDAD**|<p>( A-B ), ( B-C ), ( C-F ),</p><p>( A-B ), ( B-D ), ( D-G ),</p><p>( A-B ), ( B-E ), ( E-H ).</p>|
|**ANCHURA**|<p>( A-B ),</p><p>( B-C ), ( B-D ), ( D-E ),</p><p>( C-F ), ( D-G ), ( E-H ).</p>|



- Ejecución de las pruebas de integración.
























**Pruebas basadas en hilos.** 

|**Elemento**|**Estado**|
| :-: | :-: |
|Interfaz|Registrado, no registrado|
|BD|Activo, con problemas|
|Agenda|Disponible, no Disponible|

**Diseño de los casos de pruebas**

|**Número del caso de prueba**|**Componente**|**Descripción de lo que se probara**|**Prerrequisito**|
| :- | :- | :- | :- |
|**1**|Visualización de página de inicio|El sistema debe mostrar la página de inicio.|El cliente ha abierto la página.|
|**2**|El usuario hace un registro|El sistema pedirá datos del usuario|El programa muestra una menú de registro|
|**3**|Selección de tipo cita|El sistema debe permitir al cliente seleccionar un cita con el médico.|El programa ha mostrado la página de inicio.|
|**4**|Finaliza la solicitud de la cita|El sistema debe agendar la cita.|El programa muestra la cita solicitada.|
#


<table><tr><th colspan="2" valign="top"><a name="_7ulpm3pxp9nm"></a><b>1</b> visualización de página de inicio</th></tr>
<tr><td colspan="1" valign="top"><b>Paso</b></td><td colspan="1" valign="top"><b>Descripción de paso a seguir</b> </td><td colspan="1" valign="top"><b>Datos entrada</b></td><td colspan="1" valign="top"><b>Salida Esperada</b></td><td colspan="1" valign="top"><b>Observación</b> </td></tr>
<tr><td colspan="1" valign="top">1</td><td colspan="1" valign="top">El usuario abre la aplicación.</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación muestra la página de inicio.</td><td colspan="1" rowspan="2" valign="top">Observamos como un usuario está visualizando la interfaz </td></tr>
<tr><td colspan="1" valign="top">2</td><td colspan="1" valign="top">El usuario selecciona un menú</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación muestra menú</td></tr>
</table>


<table><tr><th colspan="2" valign="top"><b>2</b> El usuario hace un registro</th></tr>
<tr><td colspan="1" valign="top"><b>Paso</b></td><td colspan="1" valign="top"><b>Descripción de paso a seguir</b> </td><td colspan="1" valign="top"><b>Datos entrada</b></td><td colspan="1" valign="top"><b>Salida Esperada</b></td><td colspan="1" valign="top"><b>Observación</b> </td></tr>
<tr><td colspan="1" valign="top">1</td><td colspan="1" valign="top">El usuario abre el menú de registro.</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación muestra un menú de registró.</td><td colspan="1" rowspan="2" valign="top">Observamos como un usuario está visualizando los menú</td></tr>
<tr><td colspan="1" valign="top">2</td><td colspan="1" valign="top">El usuario registra sus datos</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación muestra y valida los datos del usuario</td></tr>
</table>


<table><tr><th colspan="2" valign="top"><b>3</b> Selección de tipo de cita</th></tr>
<tr><td colspan="1" valign="top"><b>Paso</b></td><td colspan="1" valign="top"><b>Descripción de paso a seguir</b> </td><td colspan="1" valign="top"><b>Datos entrada</b></td><td colspan="1" valign="top"><b>Salida Esperada</b></td><td colspan="1" valign="top"><b>Observación</b> </td></tr>
<tr><td colspan="1" valign="top">1</td><td colspan="1" valign="top">El usuario digita que tipo de cita necesita</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación muestra tipo de citas.</td><td colspan="1" rowspan="3" valign="top">Observamos como un usuario programa su cita</td></tr>
<tr><td colspan="1" valign="top">2</td><td colspan="1" valign="top">El usuario selecciona el medico disponible</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación muestra los médicos disponibles para el día</td></tr>
<tr><td colspan="1" valign="top">3</td><td colspan="1" valign="top">El usuario registra día y fecha de la cita</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación los detalles seleccionados </td></tr>
<tr><td colspan="2" valign="top"><b>4</b> Finaliza la solicitud de la cita</td></tr>
<tr><td colspan="1" valign="top"><b>Paso</b></td><td colspan="1" valign="top"><b>Descripción de paso a seguir</b> </td><td colspan="1" valign="top"><b>Datos entrada</b></td><td colspan="1" valign="top"><b>Salida Esperada</b></td><td colspan="1" valign="top"><b>Observación</b> </td></tr>
<tr><td colspan="1" valign="top">1</td><td colspan="1" valign="top">El usuario finaliza el proceso de apartado de cita.</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">La aplicación muestra que la cita fue agendada corectamente.</td><td colspan="1" valign="top">Observamos como un usuario está visualizando la interfaz </td></tr>
</table>

`  `**Tipo de prueba de sistema** 

|**Tipo de prueba**|**Rendimiento**|
| :- | :- |
|**Descripción de la prueba**|En el siguiente caso de prueba se medirá el rendimiento del aplicativo en base al uso de CPU, memoria|
|**Condiciones para la ejecución**|Se necesita instalar el programa de forma correcta|
|**Herramientas** |Administrador de tarea (Windows) |
|Detalle de la ejecución de la prueba (Pantallazos)||
|<p>resultado de la prueba: Resultado de la Prueba. </p><p></p><p></p>||

|Tipo de Prueba|Seguridad|
| :- | :- |
|Nombre de la Prueba|Seguridad de la aplicación|
|descripción de la Prueba|Mostrar la seguridad de la aplicación |
|Ambiente o condiciones previas y necesarias para su ejecución.|Necesitaremos primero, que el programa tenga sus claves para poder acceder a la base de datos|
|Herramientas y metodología utilizada.|Visual studio comunity |
|<p>Detalle de la ejecución de la prueba (Pantallazos)</p><p></p><p></p>||
|<p>Resultado de la Prueba. </p><p>Aquí podemos ver la una de las seguridades de la aplicación como son sus claves para poder acceder a la base de datos para que pueda arrancar la aplicación y también la seguridad de los datos que ponen los usuarios.</p><p></p>||


|Tipo de Prueba|Seguridad|
| :- | :- |
|Nombre de la Prueba|Seguridad de la aplicación|
|descripción de la Prueba|Mostrar la seguridad de la aplicación |
|Ambiente o condiciones previas y necesarias para su ejecución.|Necesitaremos primero, que el programa tenga sus claves para poder acceder a la base de datos|
|Herramientas y metodología utilizada.|Visual estudio code (Código de la aplicación) y navegador |
|<p>Detalle de la ejecución de la prueba (Pantallazos)</p><p></p><p></p>||
|<p>Resultado de la Prueba. </p><p>Aquí podemos ver la una de las seguridades de la aplicación como son sus claves para poder acceder a la base de datos para que pueda arrancar la aplicación y también la seguridad de los datos que ponen los usuarios.</p><p></p>||


|Tipo de Prueba|Usabilidad|
| :- | :- |
|Nombre de la Prueba|Mostrar la Usabilidad o la facilidad de la aplicación |
|descripción de la Prueba|Se va a mostrar la facilidad a la hora de querer utilizar la aplicación |
|Ambiente o condiciones previas y necesarias para su ejecución.|Lo básico que necesitaríamos para aprender cómo se utiliza el programa|
|Herramientas y metodología utilizada.|La aplicación|
|<p>Detalle de la ejecución de la prueba (Pantallazos)</p><p></p><p></p><p></p><p></p>||
|<p>Resultado de la Prueba. </p><p>Se muestra como seleccionar un producto y lo fácil que es su compra</p>||



Prueba de aceptación

|Caso de prueba con Usabilidad ||
| :- | :- |
|Utilizaremos la prueba de Usabilidad en nuestra aplicación y así nuestros usuarios podrán decir que le parecen en cuanto al uso, experiencia y necesidad.||
|Pasos de pruebas que se van a hacer es que el usuario nos cuente su experiencia en el programa, que si es fácil el uso de la aplicación.
|<p>Las pruebas de aceptación fueron un éxito. Los usuarios pudieron completar las tareas asignadas sin problemas y expresaron su satisfacción con la funcionalidad y la usabilidad del software. Los resultados de las pruebas mostraron que el software cumple con los requisitos establecidos por los usuarios. Los usuarios pudieron realizar las tareas que necesitaban con facilidad y rapidez.</p><p></p>||

1. # <a name="_toc149602647"></a><a name="_toc151682208"></a>**Diseño de caso de pruebas**

|Número del caso de prueba|Componente|Descripción de lo que se probara|Prerrequisito|
| :- | :- | :- | :- |
|1|Visualización de página de inicio|El sistema debe mostrar la página de inicio.|El cliente ha abierto la página.|
|2|El usuario hace un registro|El sistema pedirá datos del usuario|El programa muestra un menú de registro|
|3|Selección de tipo de cita|El sistema debe permitir al cliente seleccionar una cita con el médico.|El programa ha mostrado la página de inicio.|
|4|Finaliza la solicitud de la cita|El sistema debe agendar la cita.|El programa muestra la cita solicitada.|
#


<table><tr><th colspan="2" valign="top">1 visualización de página de inicio</th></tr>
<tr><td valign="top">Paso</td><td valign="top">Descripción de paso a seguir </td><td valign="top">Datos entrada</td><td valign="top">Salida Esperada</td><td valign="top">Observación </td></tr>
<tr><td valign="top">1</td><td valign="top">El usuario abre la aplicación.</td><td valign="top"></td><td valign="top">La aplicación muestra la página de inicio.</td><td rowspan="2" valign="top">Observamos como un usuario está visualizando la interfaz </td></tr>
<tr><td valign="top">2</td><td valign="top">El usuario selecciona un menú</td><td valign="top"></td><td valign="top"><a name="_toc147695790"></a>La aplicación muestra menú</td></tr>
</table>

<table><tr><th colspan="2" valign="top">2  El usuario hace un registro</th></tr>
<tr><td valign="top">Paso</td><td valign="top">Descripción de paso a seguir </td><td valign="top">Datos entrada</td><td valign="top">Salida Esperada</td><td valign="top">Observación </td></tr>
<tr><td valign="top">1</td><td valign="top">El usuario abre el menú de registro.</td><td valign="top"></td><td valign="top">La aplicación muestra un menú de registró.</td><td rowspan="2" valign="top">Observamos como un usuario está visualizando los menús</td></tr>
<tr><td valign="top">2</td><td valign="top">El usuario registra sus datos</td><td valign="top"></td><td valign="top">La aplicación muestra y valida los datos del usuario</td></tr>
</table>

<table><tr><th colspan="2" valign="top">3 selección de tipo de cita</th></tr>
<tr><td valign="top">Paso</td><td valign="top">Descripción de paso a seguir </td><td valign="top">Datos entrada</td><td valign="top">Salida Esperada</td><td valign="top">Observación </td></tr>
<tr><td valign="top">1</td><td valign="top">El usuario digita que tipo de cita necesita</td><td valign="top"></td><td valign="top">La aplicación muestra tipo de citas.</td><td rowspan="3" valign="top"><a name="_toc147695791"></a>Observamos como un usuario programa su cita</td></tr>
<tr><td valign="top">2</td><td valign="top">El usuario selecciona el medico disponible</td><td valign="top"></td><td valign="top">La aplicación muestra los médicos disponibles para el día</td></tr>
<tr><td valign="top">3</td><td valign="top"><p>El usuario registra día y fecha de la cita</p><p></p><p></p><p></p><p></p><p></p><p></p><p></p></td><td valign="top"></td><td valign="top">La aplicación los detalles seleccionados </td></tr>
<tr><td colspan="2" valign="top">4 finaliza la solicitud de la cita</td></tr>
<tr><td valign="top">Paso</td><td valign="top">Descripción de paso a seguir </td><td valign="top">Datos entrada</td><td valign="top">Salida Esperada</td><td valign="top">Observación </td></tr>
<tr><td valign="top">1</td><td valign="top">El usuario finaliza el proceso de apartado de cita.</td><td valign="top"></td><td valign="top"><p>La aplicación muestra que la cita fue agendada correctamente.</p><p></p><p></p></td><td valign="top"><a name="_toc147695792"></a>Observamos como un usuario está visualizando la interfaz</td></tr>
</table>
1. # <a name="_toc149602648"></a><a name="_toc151682209"></a>**Tipo de prueba de sistema** 

| Tipo de prueba                                                                                                                                                                                                       | Rendimiento                                                                                           |
| :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------- |
| Descripción de la prueba                                                                                                                                                                                             | En el siguiente caso de prueba se medirá el rendimiento del aplicativo en base al uso de CPU, memoria |
| Condiciones para la ejecución                                                                                                                                                                                        | Se necesita instalar el programa de forma correcta                                                    |
| Herramientas                                                                                                                                                                                                         | Visual studio comunity profile                                                                        |
| <p>Detalle de la ejecución de la prueba (Pantallazos)</p>                                                                                                                                                            |                                                                                                       |
| <p>resultado de la prueba: Resultado de la Prueba. </p><p>Aquí podemos ver como fue la prueba de rendimiento y podemos concluir que la aplicación es de consumo bajo y se puede utilizar en cualquier pc.</p><p></p> |                                                                                                       |

|Tipo de Prueba|Seguridad|
| :- | :- |
|Nombre de la Prueba|Seguridad de la aplicación|
|descripción de la Prueba|Mostrar la seguridad de la aplicación |
|Ambiente o condiciones previas y necesarias para su ejecución.|Necesitaremos primero, que el programa tenga sus claves para poder acceder a la base de datos|
|Herramientas y metodología utilizada.|Visual estudio comunity |
|<p>Detalle de la ejecución de la prueba (Pantallazos)</p><p></p><p></p>||
|<p>Resultado de la Prueba. </p><p>Aquí podemos ver la una de las seguridades de la aplicación como son sus claves para poder acceder a la base de datos para que pueda arrancar la aplicación y también la seguridad de los datos que ponen los usuarios.</p><p></p>||




|Tipo de Prueba|Seguridad|
| :- | :- |
|Nombre de la Prueba|Seguridad de la aplicación|
|descripción de la Prueba|Mostrar la seguridad de la aplicación |
|Ambiente o condiciones previas y necesarias para su ejecución.|Necesitaremos primero, que el programa tenga sus claves para poder acceder a la base de datos|
|Herramientas y metodología utilizada.|Visual estudio code (Código de la aplicación) y navegador |
|<p>Detalle de la ejecución de la prueba (Pantallazos)</p><p></p><p></p>||
|<p>Resultado de la Prueba. </p><p>Aquí podemos ver la una de las seguridades de la aplicación como son sus claves para poder acceder a la base de datos para que pueda arrancar la aplicación y también la seguridad de los datos que ponen los usuarios.</p><p></p>||

|Tipo de Prueba|Usabilidad|
| :- | :- |
|Nombre de la Prueba|Mostrar la Usabilidad o la facilidad de la aplicación |
|descripción de la Prueba|Se va a mostrar la facilidad a la hora de querer utilizar la aplicación |
|Ambiente o condiciones previas y necesarias para su ejecución.|Lo básico que necesitaríamos para aprender cómo se utiliza el programa|
|Herramientas y metodología utilizada.|La aplicación |
|<p>Detalle de la ejecución de la prueba (Pantallazos)</p><p></p><p></p><p></p><p></p>||
|<p>Resultado de la Prueba. </p><p>Se muestra como seleccionar un producto y lo fácil que es su compra</p>||

Prueba de aceptación

|Caso de prueba con Usabilidad ||
| :- | :- |
|Utilizaremos la prueba de Usabilidad en nuestra aplicación y así nuestros usuarios podrán decir que le parecen en cuanto al uso, experiencia y necesidad.||
|Pasos de pruebas que se van a hacer es que el usuario nos cuente su experiencia en el programa, que si es fácil el uso de la aplicación.||
|<p>Se hará pantallazo de las pruebas que le preguntamos a los usuarios</p><p></p><p></p><p></p><p></p><p></p>||
|<p>Las pruebas de aceptación fueron un éxito. Los usuarios pudieron completar las tareas asignadas sin problemas y expresaron su satisfacción con la funcionalidad y la usabilidad del software. Los resultados de las pruebas mostraron que el software cumple con los requisitos establecidos por los usuarios. Los usuarios pudieron realizar las tareas que necesitaban con facilidad y rapidez.</p><p></p>||


2. # <a name="_toc149602653"></a><a name="_toc151682210"></a>**METRICAS DEL SOFTWARE**
**Introducción**

Dentro del marco de nuestro proyecto orientado al desarrollo de una aplicación destinada a la gestión efectiva de pacientes en el ámbito de un consultorio médico, la evaluación y aplicación de métricas de software se convierte en un componente de importancia crucial. Nuestra plataforma está meticulosamente diseñada con el propósito de brindar una experiencia agradable y eficiente al usuario al gestionar las citas médicas en el entorno clínico.

La implementación adecuada de métricas de software no solo se erige como un compromiso inquebrantable con la búsqueda de la excelencia, sino que también encarna nuestro afán por instaurar un entorno seguro y estimulante para nuestros aprendices en formación. Este enfoque analítico no solo es esencial para evaluar la calidad intrínseca del software, sino que también sienta las bases para una mejora continua en términos de rendimiento y eficacia de nuestra aplicación. En este sentido, la medición constante a través de métricas específicas se erige como un mecanismo indispensable para optimizar y perfeccionar nuestro sistema, garantizando así un servicio médico de la más alta calidad.

**Objetivos**

El propósito primordial de la presente iniciativa consiste en delinear de manera precisa los resultados que aspiramos alcanzar al implementar métricas de software en nuestra plataforma de gestión efectiva de pacientes en un consultorio médico. Nuestros objetivos se orientan hacia los siguientes aspectos: 	

- Llevar a cabo una evaluación exhaustiva de la eficacia de nuestra aplicación en la gestión óptima de procesos dentro del entorno de un consultorio médico, con especial énfasis en la atención a pacientes.

- Identificar áreas de oportunidad que permitan perfeccionar la calidad, usabilidad y rendimiento general de la aplicación, mediante un análisis detallado de su funcionamiento.

- Cuantificar la satisfacción de los usuarios finales a través de métricas específicas, a fin de obtener una visión cuantitativa y cualitativa de la experiencia del usuario con nuestra plataforma.

- Garantizar el cumplimiento riguroso de los estándares de seguridad y privacidad necesarios para salvaguardar a nuestros usuarios más jóvenes, asegurando que la aplicación se ajuste a las normativas pertinentes en este ámbito.

Alcance

Dentro de los límites abarcados por la presente iniciativa, delineamos las categorías de medidas que implementaremos. Nos abocaremos a métricas con un enfoque específico en los siguientes dominios:

- Usabilidad: Procederemos a evaluar la facilidad de interacción con la aplicación y la experiencia del usuario.
- Rendimiento: Llevaremos a cabo mediciones que abarquen el tiempo de carga de la aplicación, la velocidad de respuesta de las funcionalidades implementadas y la eficacia global del sistema en términos de procesamiento y ejecución.
- Satisfacción del Usuario: Recopilaremos retroalimentación proveniente de los usuarios finales, tanto niños como adultos, con el fin de comprender a profundidad sus requerimientos y expectativas. Esta información se obtendrá a través de métodos que incluyen encuestas y análisis de opiniones para capturar de manera integral la percepción del usuario con respecto a la aplicación implementada.







Métricas de tamaño por funcionalidad

1) Calcule el PFS, indique cuales son: Las entradas, salidas, consultas, archivos lógicos e interfaces externas de su aplicación. (Tenga en cuenta el documento de requisitos y todas las funcionalidades para determinar las medidas)

#####
<table><tr><th colspan="1" valign="top"><a name="_hlk148105236"></a>No. Requerimiento</th><th colspan="1" valign="top">Entradas</th><th colspan="1" valign="top">Salidas</th><th colspan="1" valign="top">Consultar</th><th colspan="1" valign="top">Archivos Lógicos</th></tr>
<tr><td colspan="1" valign="top">1</td><td colspan="1" valign="top">Crear Usuario S</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td><td colspan="1" rowspan="5" valign="top"><p>Usuario</p><p>M</p></td></tr>
<tr><td colspan="1" valign="top">2</td><td colspan="1" valign="top">Modificar Usuario S</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">3</td><td colspan="1" valign="top">Eliminar Usuario S</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">4</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">Consultar Usuarios M</td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">5</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">Autenticación de Usuario M</td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">6</td><td colspan="1" valign="top">Crear Cita S</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td><td colspan="1" rowspan="4" valign="top"><p>Cita</p><p>M</p></td></tr>
<tr><td colspan="1" valign="top">7</td><td colspan="1" valign="top">Modificar Cita M</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">8</td><td colspan="1" valign="top">Eliminar Cita S</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">9</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">Consultar Citas M</td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">10</td><td colspan="1" valign="top">Crear Paciente S</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td><td colspan="1" rowspan="4" valign="top"><p>Pacientes</p><p>M</p></td></tr>
<tr><td colspan="1" valign="top">11</td><td colspan="1" valign="top">Modificar Paciente M</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">12</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">Eliminar Paciente S</td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">13</td><td colspan="1" valign="top"></td><td colspan="1" valign="top">Consultar Pacientes M</td><td colspan="1" valign="top"></td></tr>
<tr><td colspan="1" valign="top">14</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td><td colspan="1" valign="top">Filtrar Citas M</td><td colspan="1" rowspan="2" valign="top"><p>Base de Datos</p><p>M</p></td></tr>
<tr><td colspan="1" valign="top">15</td><td colspan="1" valign="top"></td><td colspan="1" valign="top"></td><td colspan="1" valign="top">Acceder a la Base de Datos C</td></tr>
</table>


1) Calcule el FCP, teniendo en cuenta el documento de RNF

|FACTOR DE AJUSTE|DESCRIPCION|PESO||
| :-: | :-: | :-: | :- |
|1|Comunicación de datos|tu aplicativo se comunica de un módulo a otro|5|
|2|Procesamientos distribuido de los datos|que tanto trabaja el aplicativo para dar un resultado|4|
|3|Rendimiento|que tanto demora en responder el aplicativo|4|
|4|Configuración fuertemente utilizadas|que tan intensivamente se utiliza el hardware del equipo donde se usa el aplicativo|4|
|5|Tasa de transacciones|con qué frecuencia se ejecutan las transacciones, diarias, semanales, mensuales|5|
|6|Entrada de datos online|qué porcentaje de la información se ingresa online|5|
|7|Diseño para la eficiencia de usuario final|la aplicación permite que el usuario final trabaje más rápido y mejor|4|
|8|actualizaciones online|cuantos archivos lógicos internos se actualizan por una transacción en línea|5|
|9|Procesamiento complejo|hay procesos lógicos o matemáticos en la aplicación|4|
|10|Reusabilidad|la aplicación se desarrolla para cumplir una o varias necesidades de los usuario|4|
|11|Facilidad de instalación|es muy difícil la instalación y la conversión al nuevo sistema|5|
|12|Facilidad de operación|como de efectivos y automatizados son los procedimiento de arranque, parada, backup y restore del sistema|4|
|13|Puestos múltiples|la aplicación fue construida para su instalación en múltiples sitios y organizaciones|4|
|14|Facilidad de cambios|la aplicación fue construida para facilitar los cambios sobre el sistema|4|
| |GRADO TOTAL DE INFLUENCIA|TOTAL|61|
||FCP = 0.65 + (0.01 \* 61) = 1.26|||

1) Calcule el tamaño en PF y el tamaño en KLOC

<table><tr><th colspan="5" valign="bottom">PFS</th></tr>
<tr><td rowspan="4">ENTRADAS</td><td valign="bottom">FACTOR DE PONDERACION</td><td valign="bottom">CANTIDAD</td><td valign="bottom">VALOR</td><td valign="bottom">RESULTADO</td></tr>
<tr><td valign="bottom">SIMPLE</td><td valign="bottom">6</td><td valign="bottom">3</td><td valign="bottom">18</td></tr>
<tr><td valign="bottom">PROMEDIO</td><td valign="bottom">2</td><td valign="bottom">4</td><td valign="bottom">8</td></tr>
<tr><td valign="bottom">COMPLEJO</td><td valign="bottom">0</td><td valign="bottom">6</td><td valign="bottom">0</td></tr>
<tr><td rowspan="3">SALIDAS</td><td valign="bottom">SIMPLE</td><td valign="bottom">1</td><td valign="bottom">4</td><td valign="bottom">4</td></tr>
<tr><td valign="bottom">PROMEDIO</td><td valign="bottom">4</td><td valign="bottom">5</td><td valign="bottom">20</td></tr>
<tr><td valign="bottom">COMPLEJO</td><td valign="bottom">0</td><td valign="bottom">7</td><td valign="bottom">0</td></tr>
<tr><td rowspan="3">CONSULTAS</td><td valign="bottom">SIMPLE</td><td valign="bottom">0</td><td valign="bottom">3</td><td valign="bottom">0</td></tr>
<tr><td valign="bottom">PROMEDIO</td><td valign="bottom">1</td><td valign="bottom">4</td><td valign="bottom">4</td></tr>
<tr><td valign="bottom">COMPLEJO</td><td valign="bottom">1</td><td valign="bottom">6</td><td valign="bottom">6</td></tr>
<tr><td rowspan="3">ARCHIVOS LOGICOS</td><td valign="bottom">SIMPLE</td><td valign="bottom">0</td><td valign="bottom">7</td><td valign="bottom">0</td></tr>
<tr><td valign="bottom">PROMEDIO</td><td valign="bottom">4</td><td valign="bottom">10</td><td valign="bottom">40</td></tr>
<tr><td valign="bottom">COMPLEJO</td><td valign="bottom">0</td><td valign="bottom">15</td><td valign="bottom">0</td></tr>
<tr><td rowspan="3">INTERFACES CON OTROS SISTEMAS</td><td valign="bottom">SIMPLE</td><td valign="bottom">0</td><td valign="bottom">5</td><td valign="bottom">0</td></tr>
<tr><td valign="bottom">PROMEDIO</td><td valign="bottom">0</td><td valign="bottom">7</td><td valign="bottom">0</td></tr>
<tr><td valign="bottom">COMPLEJO</td><td valign="bottom">0</td><td valign="bottom">10</td><td valign="bottom">0</td></tr>
<tr><td valign="bottom">TOTAL</td><td valign="bottom"> </td><td colspan="3" valign="bottom">100</td></tr>
</table>


|DATOS|VALOR|RESULTADO|
| :-: | :-: | :-: |
|PFS|100||
|FCP|61||
|FCP = 0,65 +(0,01\*PCP)||1\.26|
|PF = PFS \* FCP||126|
|LINEAS DE CODIGO POR CADA PF|58||
|KLOC = (PF \* LINEAS DE CODIGO POR CADA PF) / 1000||7\.308|
|KLOC = 7.308 |||



1) Compare el tamaño dado en LOC con los tamaños obtenidos en el punto A y realice un análisis.


|LOC = (PF \* Líneas de código por cada PF)|
| :-: |
|LOC = 126 \* 58|
|LOC = 7,308|


Considerando que se trata de una aplicación de dimensiones reducidas, caracterizada por la ausencia de una abundancia de componentes, es posible afirmar que los resultados generados se ajustarán de manera proporcional a la funcionalidad de la aplicación. Esto se logra mediante la ejecución de las operaciones previamente definidas, las cuales tienen como objetivo principal la realización de los cálculos relacionados con las Líneas de Código (LOC). La estructura simplificada del aplicativo contribuye a una gestión eficiente de las operaciones, permitiendo así la obtención de resultados precisos y coherentes con la naturaleza y alcance de la aplicación en cuestión.













**COSTO**

|**Método**|**Tamaño**|**Esfuerzo**|**Tiempo**|**Personas**|**Costos**|
| :- | :- | :- | :- | :- | :- |
|KLOC|KLOC = 7.308|<p><b>E = a(5.81)<sup>b</sup> *F</b>  </p><p><b>E = a(5.81)<sup>b</sup> *F  = 30,6</b></p><p>**a=2,4  b=1,05  F=1**</p>|<p><b>T = c E <sup>d</sup></b></p><p>**T = 2,5\*30.6^0.38 = 9.2 meses**</p><p>**c=2,5 d= 0,38** </p>|<p>**P = E/T = 30.6/8.5 = 3.6** </p><p>**P = 4 personas**</p>|<p>**C= 9.2 \* 4 \* 3’100.000**</p><p>C = 114,080,000</p>|
|Puntos de función|PF = 126|<p>E = (PF \* TXPF)/188</p><p>E = 107.65 \* 24/188 = 27 </p>|<p><b>T = 1,11 * PF<sup>0,342</sup></b></p><p><b>T = 1,11 * 107.65<sup>0,342</sup></b></p><p>T = 6.9 = 7 meses</p>|P = E/T = 27/7= 3.8 = 4 personas|C = 7 \* 4 \* 3’100.000 = 86,800,000|
|Puntos de casos de usos|UCP = 39.65|<p>**E = 175.42 \* 20** </p><p>**E = 5,908/188**</p><p>**E = 31.4**</p><p></p>|<p>**T = E/1600 Horas**</p><p>**T = 31.4/1600** </p><p>T = 0.02 \* 188 </p><p>T = 3.76 = 4 meses</p>|P = 31.4/4 = 7.9 = 8 personas|<p>**C= 3.76 \* 8 \* 3’100.000**</p><p>C = 93,248,000</p>|
|Puntos de objetos|<p>NOP = 189.2</p><p></p>|<p>**E = NOP /PROD** </p><p>**E = 189.2/7 = 27** </p><p></p>|<p><b>T<sub>DES =</sub> [2,5 x (27) ^0.38] *   SCED%/100</b></p><p>**T = 8.7 meses**</p><p></p>|<p>P = 27/8.7 = 3.10 </p><p>P = 3 personas</p>|<p>C = 8.7 \* 3 \* 3’100.000</p><p>C = 80,910,000</p>|






