# Decisiones de Tafona

Lo que se decidió, cuándo y por qué. Cada línea es una regla que el código ya
aplica o que está pendiente de aplicar (y entonces lo dice). Quien cambie una
decisión, la cambia aquí con la fecha y el motivo; no se borra la vieja, se
tacha y se dice qué la sustituye.

## 26-11-2026 (David, en la sesión que montó Tafona)

| Decisión | Por qué | Dónde se aplica |
|---|---|---|
| Juan y David **dan el OK**; desarrolla el proceso | Ellos deciden; la IA hace | todo |
| **Empezar son dos pasos:** escribir la issue y poner la etiqueta `claude` | «Me gusta que haya que hacer alguna acción para que empiece» | `trabajar.yml` (abrir una issue no arranca nada) |
| **Contestar es decidir:** si quien está asignado comenta en algo con `decide`, Tafona lo retoma sin `@claude` | Antes había que saber la palabra mágica | `trabajar.yml`, tarea «retomar» |
| Las preguntas, **en un solo sitio:** la PR | David contestó en las issues y las preguntas estaban en las PR | reglas fijas de `trabajar.yml` |
| Una PR dice **siempre «Refs #n»**, nunca «Closes» | «Closes #5» cerró la issue al fusionar y pasó a Verificado sin que nadie lo comprobara | reglas fijas; la revisora lo corrige |
| **Un fallo se convierte en issue**, sin `claude` | «Estaría bien que ante un fallo hubiera creado la issue y después solo es asignársela» | reglas de `trabajar.yml` y `revisar.yml` |
| La revisora en **modo sombra**: veredicto, no aprueba ni fusiona | Primero datos: comparar su veredicto con lo que decide David | `revisar.yml` |
| Quién decide: **David** datos de cliente, textos al público, lo legal, lo que cuesta; **Juan** lo técnico del plugin y del tema; si no está claro, los dos | — | `revisar.yml` |
| El tablero, con **piezas de GitHub**: flujos integrados del proyecto y `actions/add-to-project` | «Tendríamos que buscar algo que ya estuviera implementado» (la sincronización casera de cada 2 h se apagó) | `trabajar.yml`, `revisar.yml`, reglas del tablero |
| **Fusionar acumula; la release publica**, en todos los proyectos | Un PR no tiene que desplegar | pendiente: [publicar.md](publicar.md) |
| Desplegar una web es **copiar su tema hijo**; el contenido va como **migraciones** dentro del tema hijo, y las ejecuta el **plugin** | Un commit: si es contenido, una migración; si es código, código | pendiente: [migraciones.md](migraciones.md), tafona#2, plugin#18 |
| La auditoría, las **tareas nocturnas** y las personas son **fuentes**: abren issues, nunca PR | Encajar las piezas nuevas sin tocar el motor | pendiente: [fuentes.md](fuentes.md) |
| Tafona será **pública** y vivirá en `estrategia-web-es`, como motor para otras organizaciones | Copiarla por organización repite los arreglos N veces | pendiente: PENDIENTES.md §8 |
| Copilot de GitHub como alternativa: **aparcado** | Probarlo con datos (la misma issue a los dos) cuando el ciclo funcione | — |

## 27-11-2026 (David)

| Decisión | Por qué | Dónde se aplica |
|---|---|---|
| Tablero: *Aplicado* pasa a **Fusionado** y nace **Publicado** | Con releases, fusionado no es publicado | el tablero ([publicar](publicar.md#el-tablero-con-releases-hecho-el-27-11-2026-con-ok-de-david)) |
| **La release mueve a Publicado** y pone la etiqueta `publicado` (antes `aplicado`), que lanza la verificación | A mano se olvida; al fusionar era mentira | `publicado.yml`, llamado al final de cada flujo de publicar |
