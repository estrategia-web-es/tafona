# Repaso del 27-11-2026

Lo que se avanzó la noche del 26 al 27 y lo que espera a David o a Juan.
Este fichero se borra cuando esté repasado: lo que quede vivo pasa a
PENDIENTES.md.

## Hecho

- **Documentación:** [decisiones](decisiones.md), [fuentes](fuentes.md),
  [publicar](publicar.md), [migraciones](migraciones.md) y
  [alta de proyecto](alta-de-proyecto.md).
- **Tafona es pública.** El plugin, que es público, no podía usar sus flujos
  mientras era privada. Se revisó antes toda la historia: no hay llaves,
  tokens ni datos de servidores.
- **El plugin está enganchado** (#17 fusionada; solo tocaba el proceso).
- **`Comprobar`** en Tafona: actionlint en cada cambio de los flujos, y las
  pruebas de los guardianes en Linux. Existe porque la nocturna llegó de
  Claude con un error de YAML que la habría roto en su primer uso.
- **Tafona se revisa a sí misma:** su `tafona.yml` no tenía revisora.
- **En un repo sin web,** Claude y la revisora saben que no hay `ssh prod`.
- Cerradas tafona#7, #8 y #9 (fallos del proceso que abrieron las propias
  ejecuciones).

## Espera tu decisión (David / Juan)

| PR | Qué | La pregunta de la revisora | Nota |
|---|---|---|---|
| plugin #22 | módulo de migraciones | ¿Que escriba contenido en el `init` de cualquier visita, o solo por WP-CLI o el panel? | Es la decisión de diseño de verdad. La revisora ve además una discrepancia entre la descripción y el código. |
| plugin #21 | publicar con release (10up) | ¿Primera ejecución en seco, la 2.17.0, comparando con el zip actual? | Comprobado a mano contra `main`: v2.17.0 pasa y v9.9.9 se rechaza. Falta decidir de quién son las credenciales SVN. El flujo hay que moverlo a `.github/workflows/`. |
| tafona #6 | desplegador con release + guardián `aplicar.sh` | ¿OK a una llave que escribe en producción? | Revisado a mano. Pedidas y hechas la vuelta atrás automática y la retención de copias. **23/23 pruebas en Linux.** El contrato con el módulo, PENDIENTE hasta fusionar el módulo. |
| tafona #5 | nocturna de errores | ¿Activarla primero solo en `estrategiaweb-es`? | YAML arreglado a mano y pasado por actionlint. |

## Sin abrir, para hablarlo

- **tafona#4:** Claude no puede escribir flujos. Recomendación: que no pueda
  (es quien está revisado) y los deje en `propuestas/workflows/`.
- ~~**El tablero con releases**~~ **Hecho el 27-11 con tu OK** (tafona#11).
  Las columnas son Fusionado y Publicado; la release mueve a Publicado y pone
  la etiqueta `publicado` (antes `aplicado`), que lanza la verificación.
  Queda enganchado en las PR #6 y plugin#21. La regla «PR merged» siguió
  apuntando a Fusionado sola (lo comprobó David). Falta dar `TAFONA_TOKEN`
  al plugin cuando se rote el token.
- **Rotar el token del tablero** (PENDIENTES §0).
- `solo-lectura.sh` sigue en `auditoria-tool`. Su prueba va en vivo contra
  los servidores, así que no puede entrar en `Comprobar`. Moverlo pide otro
  nombre para su prueba.
- **estrategiaweb-es #8:** el testimonio de Luis como migración, sin `claude`
  hasta que estén el módulo y el desplegador.
