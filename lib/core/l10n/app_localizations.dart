import '../../presentation/providers/theme_provider.dart';

/// Traducciones centralizadas de la app.
///
/// Uso: `final l = ref.watch(appLocalizationsProvider);`
/// Luego: `l.guardar`, `l.cobrosTitle`, etc.
class AppLocalizations {
  const AppLocalizations._({
    // ── App ──
    required this.appName,

    // ── Bottom Navigation ──
    required this.navInicio,
    required this.navFuentes,
    required this.navHorario,
    required this.navAlumnos,
    required this.navCobros,

    // ── General / Acciones ──
    required this.guardar,
    required this.cancelar,
    required this.eliminar,
    required this.editar,
    required this.confirmar,
    required this.aceptar,
    required this.si,
    required this.no,
    required this.volver,
    required this.cerrar,
    required this.copiar,
    required this.ver,
    required this.cargando,
    required this.sinDatos,
    required this.requerido,
    required this.numeroInvalido,
    required this.errorGenerico,

    // ── Login ──
    required this.loginTitle,
    required this.loginSubtitleCreate,
    required this.loginSubtitleAccess,
    required this.usuario,
    required this.contrasena,
    required this.entrar,
    required this.crearAcceso,
    required this.credencialesIncorrectas,
    required this.accederCredenciales,
    required this.mostrarCredenciales,
    required this.noHayCredenciales,
    required this.tusCredenciales,
    required this.mostrarContrasena,
    required this.ocultarContrasena,
    required this.minCaracteres,

    // ── Onboarding ──
    required this.onboardingTitle,
    required this.onboardingSubtitle,
    required this.empezar,
    required this.configuraPerfil,
    required this.monedaRegion,

    // ── Dashboard ──
    required this.dashboardTitle,
    required this.resumenMes,
    required this.ingresosTotales,
    required this.horasTotales,
    required this.cobrosPendientes,
    required this.porFuente,
    required this.registrarSesion,

    // ── Fuentes ──
    required this.fuentesTitle,
    required this.sinFuentes,
    required this.creaUnaParaEmpezar,
    required this.nuevaFuente,
    required this.editarFuente,
    required this.nombreFuente,
    required this.nombreRequerido,
    required this.tipoFuente,
    required this.empleo,
    required this.academia,
    required this.particular,
    required this.colorIdentificativo,
    required this.eligeColor,
    required this.eliminarFuente,
    required this.confirmarEliminarFuente,
    required this.errorAlGuardar,
    required this.errorAlEliminar,

    // ── Empleo config ──
    required this.configuracionEmpleo,
    required this.salarioBase,
    required this.salarioBaseMensual,
    required this.horasSemanalesContratadas,
    required this.tarifaHoraExtra,
    required this.diaCobro,
    required this.diaCadaMes,
    required this.configuracionContrato,

    // ── Alumnos ──
    required this.alumnosTitle,
    required this.nuevoAlumno,
    required this.editarAlumno,
    required this.sinAlumnos,
    required this.sinAlumnosEnFuente,
    required this.alumnoNoEncontrado,
    required this.nombreAlumno,
    required this.fuenteIngreso,
    required this.seleccionaFuente,
    required this.tarifaPorHora,
    required this.tarifaRequerida,
    required this.duracionDefecto,
    required this.notasOpcional,
    required this.telefonoObservaciones,
    required this.eliminarAlumno,
    required this.confirmarEliminarAlumno,
    required this.anadirAlumno,
    required this.traspasarAlumno,
    required this.traspasar,
    required this.sesionesMantenidas,
    required this.alumnoTraspasado,
    required this.noHayOtrasFuentes,
    required this.nuevaFuenteLabel,

    // ── Sesiones ──
    required this.sesionesTitle,
    required this.nuevaSesionRecurrente,
    required this.editarSesionRecurrente,
    required this.claseUnica,
    required this.claseUnicaDesc,
    required this.fecha,
    required this.seleccionar,
    required this.diasSemana,
    required this.horaInicio,
    required this.fin,
    required this.duracion,
    required this.alumnoOpcional,
    required this.sinAlumnoEspecifico,
    required this.importeEuro,
    required this.editarImporte,
    required this.introduceImporte,
    required this.confirmarSesion,
    required this.seleccionaDia,
    required this.seleccionaFechaUnica,
    required this.introduceImporteSesion,
    required this.tarifaGlobalEditable,
    required this.tarifaAlumnoEditable,

    // ── Horario ──
    required this.horarioTitle,
    required this.hoy,
    required this.dia,
    required this.semana,
    required this.mes,
    required this.anio,

    // ── Registro sesión sheet ──
    required this.sesionCancelada,
    required this.sesionRealizada,
    required this.sesionCanceladaDesc,
    required this.sesionRealizadaDesc,
    required this.seRealizo,
    required this.noSeDioMarcarCancelada,
    required this.importeSesion,
    required this.cobreAhora,
    required this.pendiente,
    required this.introduceImporteValido,
    required this.sesionConfirmadaCobrada,
    required this.sesionConfirmadaPendiente,
    required this.sesionRegistradaHoras,
    required this.sesionMarcadaCancelada,

    // ── Cobros ──
    required this.cobrosTitle,
    required this.todoCobrado,
    required this.totalPendiente,
    required this.cobrado,
    required this.parcial,
    required this.marcarCobrado,
    required this.dejarPendiente,
    required this.detalleCobro,
    required this.cobroNoEncontrado,
    required this.importe,
    required this.estado,
    required this.modo,
    required this.periodo,
    required this.fechaCobro,
    required this.cobradoParcial,
    required this.notas,
    required this.registrarCobroParcial,
    required this.cobroParcialTitle,
    required this.importeCobrado,
    required this.introduceMonto,
    required this.noPuedeSuperarMonto,
    required this.sesionesEsteMes,
    required this.sinSesionesEsteMes,

    // ── Horas Extra ──
    required this.horasExtraTitle,
    required this.sinFuenteEmpleo,
    required this.esteMesRegistradas,
    required this.importeExtraProyectado,
    required this.horasTrabajadasMes,
    required this.horasContratadasMes,
    required this.horasExtraMes,
    required this.extraACobrar,
    required this.sinRegistros,
    required this.historial,
    required this.registrarHorasExtra,
    required this.horasExtra,
    required this.sinAlumno,
    required this.eliminarRegistro,
    required this.confirmarEliminarHoraExtra,
    required this.confirmarEliminarSesion,
    required this.registroEliminado,
    required this.eliminarSesion,
    required this.confirmarEliminarSesionCalendario,
    required this.sesionEliminada,

    // ── Ajustes ──
    required this.ajustesTitle,
    required this.miCuenta,
    required this.miPerfil,
    required this.nombreDatosPersonales,
    required this.apariencia,
    required this.tema,
    required this.sistema,
    required this.claro,
    required this.oscuro,
    required this.idioma,
    required this.idiomaApp,
    required this.tarifasCondiciones,
    required this.tarifas,
    required this.tarifaGlobalPorFuente,
    required this.datos,
    required this.sincronizacion,
    required this.proximamenteBackup,
    required this.exportarCopia,
    required this.importarCopia,
    required this.exportarDesc,
    required this.importarDesc,
    required this.confirmarImportar,
    required this.exportExitoso,
    required this.importExitoso,
    required this.archivoInvalido,
    required this.conectarDrive,
    required this.desconectarDrive,
    required this.subirDrive,
    required this.restaurarDrive,
    required this.ultimaCopia,
    required this.sinCopiaPrevia,
    required this.backupDriveExitoso,
    required this.restaurarDriveExitoso,
    required this.confirmarRestaurarDrive,
    required this.copiaLocal,
    required this.googleDrive,
    required this.copiaAutomatica,
    required this.copiaAutomaticaDesc,
    required this.horaCopia,
    required this.tipoCopia,
    required this.tipoLocal,
    required this.ultimaCopiaAuto,
    required this.copiaActivada,
    required this.copiaDesactivada,
    required this.driveNecesitaConexion,
    required this.ubicacionCopia,
    required this.rutaCopiada,
    required this.compartirCopia,
    required this.sinCopiaLocal,
    required this.versionInfo,

    // ── Perfil ──
    required this.nombre,
    required this.tuNombre,
    required this.preferencias,
    required this.moneda,
    required this.masOpcionesProximamente,
    required this.perfilActualizado,

    // ── Tarifas ──
    required this.tarifasTitle,
    required this.comoFunciona,
    required this.jerarquiaTarifas,
    required this.tarifaGlobal,
    required this.tarifaPorAlumno,
    required this.sinAlumnosRegistrados,
    required this.tarifaGlobalGuardada,
    required this.introduceNumeroValido,
    required this.porHora,
    required this.tarifaDe,

    // ── Dashboard widgets ──
    required this.ingresosMes,
    required this.horas,
    required this.todoAlDia,
    required this.cobro,

    // ── Fuentes tabs ──
    required this.noAcademiaConfigurada,
    required this.sinAlumnosAcademia,
    required this.sinConfiguracionEmpleo,
    required this.noEmpleoConfigurada,
    required this.noParticularConfigurada,
    required this.sinAlumnosParticulares,
    required this.porSesionEfectivo,
    required this.porSesionMin,
    required this.alumno,
    required this.deCadaMes,

    // ── Horario widgets ──
    required this.actividad,
    required this.menos,
    required this.mas,
    required this.sinClasesEsteDia,
    required this.clasesDeHoy,
    required this.sesion,
    required this.sesiones,
    required this.diasAbreviados,
    required this.queOcurrioSesion,

    // ── Registro sesión extra ──
    required this.queSesionFue,
    required this.cuandoCobras,

    // ── Login extra ──
    required this.olvidasteContrasena,

    // ── Cobro detalle extra ──
    required this.maxLabel,

    // ── Notificaciones ──
    required this.notificaciones,
    required this.recordatorioClases,
    required this.minutosAntes,
    required this.notificacionesActivadas,
    required this.notificacionesDesactivadas,
  });

  // ── App ──
  final String appName;

  // ── Bottom Navigation ──
  final String navInicio;
  final String navFuentes;
  final String navHorario;
  final String navAlumnos;
  final String navCobros;

  // ── General / Acciones ──
  final String guardar;
  final String cancelar;
  final String eliminar;
  final String editar;
  final String confirmar;
  final String aceptar;
  final String si;
  final String no;
  final String volver;
  final String cerrar;
  final String copiar;
  final String ver;
  final String cargando;
  final String sinDatos;
  final String requerido;
  final String numeroInvalido;
  final String errorGenerico;

  // ── Login ──
  final String loginTitle;
  final String loginSubtitleCreate;
  final String loginSubtitleAccess;
  final String usuario;
  final String contrasena;
  final String entrar;
  final String crearAcceso;
  final String credencialesIncorrectas;
  final String accederCredenciales;
  final String mostrarCredenciales;
  final String noHayCredenciales;
  final String tusCredenciales;
  final String mostrarContrasena;
  final String ocultarContrasena;
  final String minCaracteres;

  // ── Onboarding ──
  final String onboardingTitle;
  final String onboardingSubtitle;
  final String empezar;
  final String configuraPerfil;
  final String monedaRegion;

  // ── Dashboard ──
  final String dashboardTitle;
  final String resumenMes;
  final String ingresosTotales;
  final String horasTotales;
  final String cobrosPendientes;
  final String porFuente;
  final String registrarSesion;

  // ── Fuentes ──
  final String fuentesTitle;
  final String sinFuentes;
  final String creaUnaParaEmpezar;
  final String nuevaFuente;
  final String editarFuente;
  final String nombreFuente;
  final String nombreRequerido;
  final String tipoFuente;
  final String empleo;
  final String academia;
  final String particular;
  final String colorIdentificativo;
  final String eligeColor;
  final String eliminarFuente;
  final String confirmarEliminarFuente;
  final String errorAlGuardar;
  final String errorAlEliminar;

  // ── Empleo config ──
  final String configuracionEmpleo;
  final String salarioBase;
  final String salarioBaseMensual;
  final String horasSemanalesContratadas;
  final String tarifaHoraExtra;
  final String diaCobro;
  final String diaCadaMes;
  final String configuracionContrato;

  // ── Alumnos ──
  final String alumnosTitle;
  final String nuevoAlumno;
  final String editarAlumno;
  final String sinAlumnos;
  final String sinAlumnosEnFuente;
  final String alumnoNoEncontrado;
  final String nombreAlumno;
  final String fuenteIngreso;
  final String seleccionaFuente;
  final String tarifaPorHora;
  final String tarifaRequerida;
  final String duracionDefecto;
  final String notasOpcional;
  final String telefonoObservaciones;
  final String eliminarAlumno;
  final String confirmarEliminarAlumno;
  final String anadirAlumno;
  final String traspasarAlumno;
  final String traspasar;
  final String sesionesMantenidas;
  final String alumnoTraspasado;
  final String noHayOtrasFuentes;
  final String nuevaFuenteLabel;

  // ── Sesiones ──
  final String sesionesTitle;
  final String nuevaSesionRecurrente;
  final String editarSesionRecurrente;
  final String claseUnica;
  final String claseUnicaDesc;
  final String fecha;
  final String seleccionar;
  final String diasSemana;
  final String horaInicio;
  final String fin;
  final String duracion;
  final String alumnoOpcional;
  final String sinAlumnoEspecifico;
  final String importeEuro;
  final String editarImporte;
  final String introduceImporte;
  final String confirmarSesion;
  final String seleccionaDia;
  final String seleccionaFechaUnica;
  final String introduceImporteSesion;
  final String tarifaGlobalEditable;
  final String tarifaAlumnoEditable;

  // ── Horario ──
  final String horarioTitle;
  final String hoy;
  final String dia;
  final String semana;
  final String mes;
  final String anio;

  // ── Registro sesión sheet ──
  final String sesionCancelada;
  final String sesionRealizada;
  final String sesionCanceladaDesc;
  final String sesionRealizadaDesc;
  final String seRealizo;
  final String noSeDioMarcarCancelada;
  final String importeSesion;
  final String cobreAhora;
  final String pendiente;
  final String introduceImporteValido;
  final String sesionConfirmadaCobrada;
  final String sesionConfirmadaPendiente;
  final String sesionRegistradaHoras;
  final String sesionMarcadaCancelada;

  // ── Cobros ──
  final String cobrosTitle;
  final String todoCobrado;
  final String totalPendiente;
  final String cobrado;
  final String parcial;
  final String marcarCobrado;
  final String dejarPendiente;
  final String detalleCobro;
  final String cobroNoEncontrado;
  final String importe;
  final String estado;
  final String modo;
  final String periodo;
  final String fechaCobro;
  final String cobradoParcial;
  final String notas;
  final String registrarCobroParcial;
  final String cobroParcialTitle;
  final String importeCobrado;
  final String introduceMonto;
  final String noPuedeSuperarMonto;
  final String sesionesEsteMes;
  final String sinSesionesEsteMes;

  // ── Horas Extra ──
  final String horasExtraTitle;
  final String sinFuenteEmpleo;
  final String esteMesRegistradas;
  final String importeExtraProyectado;
  final String horasTrabajadasMes;
  final String horasContratadasMes;
  final String horasExtraMes;
  final String extraACobrar;
  final String sinRegistros;
  final String historial;
  final String registrarHorasExtra;
  final String horasExtra;
  final String sinAlumno;
  final String eliminarRegistro;
  final String confirmarEliminarHoraExtra;
  final String confirmarEliminarSesion;
  final String registroEliminado;
  final String eliminarSesion;
  final String confirmarEliminarSesionCalendario;
  final String sesionEliminada;

  // ── Ajustes ──
  final String ajustesTitle;
  final String miCuenta;
  final String miPerfil;
  final String nombreDatosPersonales;
  final String apariencia;
  final String tema;
  final String sistema;
  final String claro;
  final String oscuro;
  final String idioma;
  final String idiomaApp;
  final String tarifasCondiciones;
  final String tarifas;
  final String tarifaGlobalPorFuente;
  final String datos;
  final String sincronizacion;
  final String proximamenteBackup;
  final String exportarCopia;
  final String importarCopia;
  final String exportarDesc;
  final String importarDesc;
  final String confirmarImportar;
  final String exportExitoso;
  final String importExitoso;
  final String archivoInvalido;
  final String conectarDrive;
  final String desconectarDrive;
  final String subirDrive;
  final String restaurarDrive;
  final String ultimaCopia;
  final String sinCopiaPrevia;
  final String backupDriveExitoso;
  final String restaurarDriveExitoso;
  final String confirmarRestaurarDrive;
  final String copiaLocal;
  final String googleDrive;
  final String copiaAutomatica;
  final String copiaAutomaticaDesc;
  final String horaCopia;
  final String tipoCopia;
  final String tipoLocal;
  final String ultimaCopiaAuto;
  final String copiaActivada;
  final String copiaDesactivada;
  final String driveNecesitaConexion;
  final String ubicacionCopia;
  final String rutaCopiada;
  final String compartirCopia;
  final String sinCopiaLocal;
  final String versionInfo;

  // ── Perfil ──
  final String nombre;
  final String tuNombre;
  final String preferencias;
  final String moneda;
  final String masOpcionesProximamente;
  final String perfilActualizado;

  // ── Tarifas ──
  final String tarifasTitle;
  final String comoFunciona;
  final String jerarquiaTarifas;
  final String tarifaGlobal;
  final String tarifaPorAlumno;
  final String sinAlumnosRegistrados;
  final String tarifaGlobalGuardada;
  final String introduceNumeroValido;
  final String porHora;
  final String tarifaDe;

  // ── Dashboard widgets ──
  final String ingresosMes;
  final String horas;
  final String todoAlDia;
  final String cobro;

  // ── Fuentes tabs ──
  final String noAcademiaConfigurada;
  final String sinAlumnosAcademia;
  final String sinConfiguracionEmpleo;
  final String noEmpleoConfigurada;
  final String noParticularConfigurada;
  final String sinAlumnosParticulares;
  final String porSesionEfectivo;
  final String porSesionMin;
  final String alumno;
  final String deCadaMes;

  // ── Horario widgets ──
  final String actividad;
  final String menos;
  final String mas;
  final String sinClasesEsteDia;
  final String clasesDeHoy;
  final String sesion;
  final String sesiones;
  final String diasAbreviados;
  final String queOcurrioSesion;

  // ── Registro sesión extra ──
  final String queSesionFue;
  final String cuandoCobras;

  // ── Login extra ──
  final String olvidasteContrasena;

  // ── Cobro detalle extra ──
  final String maxLabel;

  // ── Notificaciones ──
  final String notificaciones;
  final String recordatorioClases;
  final String minutosAntes;
  final String notificacionesActivadas;
  final String notificacionesDesactivadas;

  // ── Factory ──
  factory AppLocalizations.of(AppLocale locale) => switch (locale) {
        AppLocale.es => _es,
        AppLocale.en => _en,
        AppLocale.it => _it,
      };

  // ═══════════════════════════════════════════════════════════════════
  // ESPAÑOL
  // ═══════════════════════════════════════════════════════════════════
  static const _es = AppLocalizations._(
    appName: 'Teacher Finance',
    navInicio: 'Inicio',
    navFuentes: 'Fuentes',
    navHorario: 'Horario',
    navAlumnos: 'Alumnos',
    navCobros: 'Cobros',
    guardar: 'Guardar',
    cancelar: 'Cancelar',
    eliminar: 'Eliminar',
    editar: 'Editar',
    confirmar: 'Confirmar',
    aceptar: 'Aceptar',
    si: 'Sí',
    no: 'No',
    volver: 'Volver',
    cerrar: 'Cerrar',
    copiar: 'Copiar',
    ver: 'Ver',
    cargando: 'Cargando...',
    sinDatos: 'Sin datos',
    requerido: 'Requerido',
    numeroInvalido: 'Número inválido',
    errorGenerico: 'Ha ocurrido un error',
    loginTitle: 'Teacher Finance',
    loginSubtitleCreate: 'Crea tus credenciales de acceso',
    loginSubtitleAccess: 'Accede a tu cuenta',
    usuario: 'Usuario',
    contrasena: 'Contraseña',
    entrar: 'Entrar',
    crearAcceso: 'Crear acceso',
    credencialesIncorrectas: 'Usuario o contraseña incorrectos',
    accederCredenciales: 'Acceder a credenciales',
    mostrarCredenciales: 'Se mostrarán tus credenciales guardadas. ¿Continuar?',
    noHayCredenciales: 'No hay credenciales guardadas aún',
    tusCredenciales: 'Tus credenciales',
    mostrarContrasena: 'Mostrar contraseña',
    ocultarContrasena: 'Ocultar',
    minCaracteres: 'Mínimo 4 caracteres',
    onboardingTitle: '¡Bienvenida a Teacher Finance!',
    onboardingSubtitle: 'Gestiona tus clases, horas y cobros desde el móvil.',
    empezar: 'Empezar',
    configuraPerfil: 'Configura tu perfil',
    monedaRegion: 'Moneda y región',
    dashboardTitle: 'Inicio',
    resumenMes: 'Resumen del mes',
    ingresosTotales: 'Ingresos totales',
    horasTotales: 'Horas totales',
    cobrosPendientes: 'Cobros pendientes',
    porFuente: 'Por fuente',
    registrarSesion: 'Registrar sesión',
    fuentesTitle: 'Fuentes de ingreso',
    sinFuentes: 'Sin fuentes de ingreso',
    creaUnaParaEmpezar: 'Crea una para empezar',
    nuevaFuente: 'Nueva fuente',
    editarFuente: 'Editar fuente',
    nombreFuente: 'Nombre de la fuente',
    nombreRequerido: 'Nombre requerido',
    tipoFuente: 'Tipo de fuente',
    empleo: 'Empleo',
    academia: 'Academia',
    particular: 'Particular',
    colorIdentificativo: 'Color identificativo',
    eligeColor: 'Elige un color',
    eliminarFuente: 'Eliminar fuente',
    confirmarEliminarFuente:
        'Se eliminarán también todos los alumnos, sesiones y cobros asociados a esta fuente. Esta acción no se puede deshacer.',
    errorAlGuardar: 'Error al guardar',
    errorAlEliminar: 'Error al eliminar',
    configuracionEmpleo: 'Configuración del empleo',
    salarioBase: 'Salario base',
    salarioBaseMensual: 'Salario base mensual (€)',
    horasSemanalesContratadas: 'Horas semanales contratadas',
    tarifaHoraExtra: 'Tarifa hora extra',
    diaCobro: 'Día de cobro',
    diaCadaMes: 'de cada mes',
    configuracionContrato: 'Configuración contrato',
    alumnosTitle: 'Alumnos',
    nuevoAlumno: 'Nuevo alumno',
    editarAlumno: 'Editar alumno',
    sinAlumnos: 'Aún no tienes alumnos registrados',
    sinAlumnosEnFuente: 'Sin alumnos en esta fuente',
    alumnoNoEncontrado: 'Alumno no encontrado',
    nombreAlumno: 'Nombre del alumno',
    fuenteIngreso: 'Fuente de ingreso',
    seleccionaFuente: 'Selecciona una fuente',
    tarifaPorHora: 'Tarifa por hora (€/h)',
    tarifaRequerida: 'Tarifa requerida',
    duracionDefecto: 'Duración por defecto',
    notasOpcional: 'Notas (opcional)',
    telefonoObservaciones: 'Teléfono, observaciones...',
    eliminarAlumno: 'Eliminar alumno',
    confirmarEliminarAlumno:
        '¿Eliminar este alumno? Las sesiones registradas se mantendrán.',
    anadirAlumno: 'Añadir alumno',
    traspasarAlumno: 'Traspasar alumno',
    traspasar: 'Traspasar',
    sesionesMantenidas:
        'Las sesiones anteriores mantendrán su fuente original.',
    alumnoTraspasado: 'Alumno traspasado',
    noHayOtrasFuentes: 'No hay otras fuentes disponibles',
    nuevaFuenteLabel: 'Nueva fuente',
    sesionesTitle: 'Sesiones',
    nuevaSesionRecurrente: 'Nueva sesión recurrente',
    editarSesionRecurrente: 'Editar sesión recurrente',
    claseUnica: 'Clase única',
    claseUnicaDesc: 'Solo ocurre una vez, en una fecha concreta',
    fecha: 'Fecha',
    seleccionar: 'Seleccionar',
    diasSemana: 'Días de la semana',
    horaInicio: 'Inicio',
    fin: 'Fin',
    duracion: 'Duración',
    alumnoOpcional: 'Alumno (opcional)',
    sinAlumnoEspecifico: 'Sin alumno específico',
    importeEuro: 'Importe (€)',
    editarImporte: 'Editar importe',
    introduceImporte: 'Introduce el importe',
    confirmarSesion: 'Confirmar sesión',
    seleccionaDia: 'Selecciona al menos un día de la semana',
    seleccionaFechaUnica: 'Selecciona una fecha para la clase única',
    introduceImporteSesion: 'Introduce el importe de la sesión',
    tarifaGlobalEditable: 'Tarifa global · editable',
    tarifaAlumnoEditable: 'Tarifa del alumno · editable',
    horarioTitle: 'Horario',
    hoy: 'Hoy',
    dia: 'Día',
    semana: 'Semana',
    mes: 'Mes',
    anio: 'Año',
    sesionCancelada: 'Sesión cancelada',
    sesionRealizada: 'Sesión realizada',
    sesionCanceladaDesc: 'Esta sesión fue marcada como no realizada.',
    sesionRealizadaDesc: 'Esta sesión ya está registrada como realizada.',
    seRealizo: 'Se realizó',
    noSeDioMarcarCancelada: 'No se dio — marcar cancelada',
    importeSesion: 'Importe de la sesión',
    cobreAhora: 'Cobré ahora',
    pendiente: 'Pendiente',
    introduceImporteValido: 'Introduce un importe válido',
    sesionConfirmadaCobrada: 'Sesión confirmada y cobrada',
    sesionConfirmadaPendiente: 'Sesión confirmada — cobro pendiente',
    sesionRegistradaHoras: 'Sesión registrada — horas añadidas',
    sesionMarcadaCancelada: 'Sesión marcada como cancelada',
    cobrosTitle: 'Cobros',
    todoCobrado: '¡Todo cobrado!',
    totalPendiente: 'Total pendiente',
    cobrado: 'Cobrado',
    parcial: 'Parcial',
    marcarCobrado: 'Marcar cobrado',
    dejarPendiente: 'Dejar pendiente',
    detalleCobro: 'Detalle del cobro',
    cobroNoEncontrado: 'Cobro no encontrado',
    importe: 'Importe',
    estado: 'Estado',
    modo: 'Modo',
    periodo: 'Período',
    fechaCobro: 'Fecha cobro',
    cobradoParcial: 'Cobrado parcial',
    notas: 'Notas',
    registrarCobroParcial: 'Registrar cobro parcial',
    cobroParcialTitle: 'Cobro parcial',
    importeCobrado: 'Importe cobrado (€)',
    introduceMonto: 'Introduce un importe',
    noPuedeSuperarMonto: 'No puede superar el total',
    sesionesEsteMes: 'Sesiones este mes',
    sinSesionesEsteMes: 'Sin sesiones este mes',
    horasExtraTitle: 'Horas extra',
    sinFuenteEmpleo: 'No hay fuente de empleo configurada.',
    esteMesRegistradas: 'Este mes registradas',
    importeExtraProyectado: 'Importe extra proyectado',
    horasTrabajadasMes: 'Sueldo esperado este mes',
    horasContratadasMes: 'Horas contratadas este mes',
    horasExtraMes: 'Horas extra este mes',
    extraACobrar: 'Extra a cobrar',
    sinRegistros: 'Sin registros aún.\nPulsa + para añadir horas extra.',
    historial: 'Historial',
    registrarHorasExtra: 'Registrar horas extra',
    horasExtra: 'Horas extra',
    sinAlumno: 'Sin alumno',
    eliminarRegistro: 'Eliminar registro',
    confirmarEliminarHoraExtra: '¿Eliminar este registro de horas extra?',
    confirmarEliminarSesion:
        '¿Eliminar esta sesión registrada? Se borrarán también los cobros o horas extra vinculados.',
    registroEliminado: 'Registro eliminado',
    eliminarSesion: 'Eliminar sesión',
    confirmarEliminarSesionCalendario:
        '¿Eliminar esta sesión del calendario? Se eliminará permanentemente.',
    sesionEliminada: 'Sesión eliminada',
    ajustesTitle: 'Ajustes',
    miCuenta: 'Mi cuenta',
    miPerfil: 'Mi perfil',
    nombreDatosPersonales: 'Nombre y datos personales',
    apariencia: 'Apariencia',
    tema: 'Tema',
    sistema: 'Sistema',
    claro: 'Claro',
    oscuro: 'Oscuro',
    idioma: 'Idioma',
    idiomaApp: 'Idioma de la app',
    tarifasCondiciones: 'Tarifas y condiciones',
    tarifas: 'Tarifas',
    tarifaGlobalPorFuente: 'Tarifa global y por fuente',
    datos: 'Datos',
    sincronizacion: 'Copia de seguridad',
    proximamenteBackup: 'Exporta, importa o usa Google Drive',
    exportarCopia: 'Exportar copia de seguridad',
    importarCopia: 'Importar copia de seguridad',
    exportarDesc: 'Guarda tus datos en un archivo',
    importarDesc: 'Restaura datos desde un archivo',
    confirmarImportar:
        '¿Importar copia? Esto reemplazará todos los datos actuales.',
    exportExitoso: 'Copia exportada correctamente',
    importExitoso:
        'Datos importados. Reinicia la app para aplicar los cambios.',
    archivoInvalido: 'El archivo seleccionado no es una copia válida',
    conectarDrive: 'Conectar con Google Drive',
    desconectarDrive: 'Desconectar cuenta',
    subirDrive: 'Subir a Google Drive',
    restaurarDrive: 'Restaurar desde Google Drive',
    ultimaCopia: 'Última copia',
    sinCopiaPrevia: 'No hay copia previa',
    backupDriveExitoso: 'Copia subida a Google Drive',
    restaurarDriveExitoso:
        'Datos restaurados desde Google Drive. Reinicia la app.',
    confirmarRestaurarDrive:
        '¿Restaurar desde Google Drive? Esto reemplazará todos los datos actuales.',
    copiaLocal: 'Copia local',
    googleDrive: 'Google Drive',
    copiaAutomatica: 'Copia automática',
    copiaAutomaticaDesc: 'Programa una copia diaria a la hora que elijas',
    horaCopia: 'Hora de la copia',
    tipoCopia: 'Tipo de copia',
    tipoLocal: 'Local',
    ultimaCopiaAuto: 'Última copia automática',
    copiaActivada: 'Copia automática activada',
    copiaDesactivada: 'Copia automática desactivada',
    driveNecesitaConexion: 'Conecta tu cuenta de Google Drive primero',
    ubicacionCopia: 'Ubicación de la copia',
    rutaCopiada: 'Ruta copiada al portapapeles',
    compartirCopia: 'Compartir archivo de copia',
    sinCopiaLocal: 'Aún no hay copia local',
    versionInfo:
        'Teacher Finance v1.0.0\nOffline-first — tus datos siempre contigo',
    nombre: 'Nombre',
    tuNombre: 'Tu nombre',
    preferencias: 'Preferencias',
    moneda: 'Moneda',
    masOpcionesProximamente: 'Más opciones próximamente',
    perfilActualizado: 'Perfil actualizado',
    tarifasTitle: 'Tarifas',
    comoFunciona: '¿Cómo funciona?',
    jerarquiaTarifas:
        '1. Tarifa del alumno (si tiene)\n2. Tarifa de la fuente\n3. Tarifa global (fallback)',
    tarifaGlobal: 'Tarifa global',
    tarifaPorAlumno: 'Tarifa por alumno',
    sinAlumnosRegistrados: 'No hay alumnos registrados todavía.',
    tarifaGlobalGuardada: 'Tarifa global guardada',
    introduceNumeroValido: 'Introduce un número válido',
    porHora: '/h',
    tarifaDe: 'Tarifa de',
    ingresosMes: 'Ingresos del mes',
    horas: 'Horas',
    todoAlDia: 'Todo al día',
    cobro: 'cobro',
    noAcademiaConfigurada: 'No hay academia configurada',
    sinAlumnosAcademia: 'Sin alumnos en esta academia',
    sinConfiguracionEmpleo: 'Sin configuración de empleo',
    noEmpleoConfigurada: 'No hay fuente de empleo configurada',
    noParticularConfigurada: 'No hay fuente de particulares configurada',
    sinAlumnosParticulares: 'Sin alumnos particulares aún',
    porSesionEfectivo: '/sesión · Efectivo',
    porSesionMin: '/sesión',
    alumno: 'Alumno',
    deCadaMes: 'de cada mes',
    actividad: 'Actividad',
    menos: 'Menos',
    mas: 'Más',
    sinClasesEsteDia: 'Sin clases este día',
    clasesDeHoy: 'Clases de hoy',
    sesion: 'sesión',
    sesiones: 'sesiones',
    diasAbreviados: 'L,M,X,J,V,S,D',
    queOcurrioSesion: '¿Qué ocurrió con esta sesión?',
    queSesionFue: '¿Qué sesión fue?',
    cuandoCobras: '¿Cuándo cobras?',
    olvidasteContrasena: '¿Olvidaste tu contraseña?',
    maxLabel: 'Máx.',
    notificaciones: 'Notificaciones',
    recordatorioClases: 'Recordatorio antes de cada clase',
    minutosAntes: 'min antes',
    notificacionesActivadas: 'Notificaciones activadas',
    notificacionesDesactivadas: 'Notificaciones desactivadas',
  );

  // ═══════════════════════════════════════════════════════════════════
  // ENGLISH
  // ═══════════════════════════════════════════════════════════════════
  static const _en = AppLocalizations._(
    appName: 'Teacher Finance',
    navInicio: 'Home',
    navFuentes: 'Sources',
    navHorario: 'Schedule',
    navAlumnos: 'Students',
    navCobros: 'Payments',
    guardar: 'Save',
    cancelar: 'Cancel',
    eliminar: 'Delete',
    editar: 'Edit',
    confirmar: 'Confirm',
    aceptar: 'Accept',
    si: 'Yes',
    no: 'No',
    volver: 'Back',
    cerrar: 'Close',
    copiar: 'Copy',
    ver: 'View',
    cargando: 'Loading...',
    sinDatos: 'No data',
    requerido: 'Required',
    numeroInvalido: 'Invalid number',
    errorGenerico: 'An error occurred',
    loginTitle: 'Teacher Finance',
    loginSubtitleCreate: 'Create your access credentials',
    loginSubtitleAccess: 'Log in to your account',
    usuario: 'Username',
    contrasena: 'Password',
    entrar: 'Log in',
    crearAcceso: 'Create access',
    credencialesIncorrectas: 'Incorrect username or password',
    accederCredenciales: 'View credentials',
    mostrarCredenciales: 'Your saved credentials will be shown. Continue?',
    noHayCredenciales: 'No saved credentials yet',
    tusCredenciales: 'Your credentials',
    mostrarContrasena: 'Show password',
    ocultarContrasena: 'Hide',
    minCaracteres: 'Minimum 4 characters',
    onboardingTitle: 'Welcome to Teacher Finance!',
    onboardingSubtitle:
        'Manage your classes, hours and payments from your phone.',
    empezar: 'Get started',
    configuraPerfil: 'Set up your profile',
    monedaRegion: 'Currency and region',
    dashboardTitle: 'Home',
    resumenMes: 'Monthly summary',
    ingresosTotales: 'Total income',
    horasTotales: 'Total hours',
    cobrosPendientes: 'Pending payments',
    porFuente: 'By source',
    registrarSesion: 'Log session',
    fuentesTitle: 'Income sources',
    sinFuentes: 'No income sources',
    creaUnaParaEmpezar: 'Create one to get started',
    nuevaFuente: 'New source',
    editarFuente: 'Edit source',
    nombreFuente: 'Source name',
    nombreRequerido: 'Name required',
    tipoFuente: 'Source type',
    empleo: 'Employment',
    academia: 'Academy',
    particular: 'Private',
    colorIdentificativo: 'Identifying colour',
    eligeColor: 'Choose a colour',
    eliminarFuente: 'Delete source',
    confirmarEliminarFuente:
        'All students, sessions and payments linked to this source will also be deleted. This action cannot be undone.',
    errorAlGuardar: 'Error saving',
    errorAlEliminar: 'Error deleting',
    configuracionEmpleo: 'Employment settings',
    salarioBase: 'Base salary',
    salarioBaseMensual: 'Monthly base salary (€)',
    horasSemanalesContratadas: 'Contracted weekly hours',
    tarifaHoraExtra: 'Overtime rate',
    diaCobro: 'Payday',
    diaCadaMes: 'of each month',
    configuracionContrato: 'Contract details',
    alumnosTitle: 'Students',
    nuevoAlumno: 'New student',
    editarAlumno: 'Edit student',
    sinAlumnos: 'No students registered yet',
    sinAlumnosEnFuente: 'No students in this source',
    alumnoNoEncontrado: 'Student not found',
    nombreAlumno: 'Student name',
    fuenteIngreso: 'Income source',
    seleccionaFuente: 'Select a source',
    tarifaPorHora: 'Hourly rate (€/h)',
    tarifaRequerida: 'Rate required',
    duracionDefecto: 'Default duration',
    notasOpcional: 'Notes (optional)',
    telefonoObservaciones: 'Phone, observations...',
    eliminarAlumno: 'Delete student',
    confirmarEliminarAlumno:
        'Delete this student? Recorded sessions will be kept.',
    anadirAlumno: 'Add student',
    traspasarAlumno: 'Transfer student',
    traspasar: 'Transfer',
    sesionesMantenidas: 'Previous sessions will keep their original source.',
    alumnoTraspasado: 'Student transferred',
    noHayOtrasFuentes: 'No other sources available',
    nuevaFuenteLabel: 'New source',
    sesionesTitle: 'Sessions',
    nuevaSesionRecurrente: 'New recurring session',
    editarSesionRecurrente: 'Edit recurring session',
    claseUnica: 'One-off class',
    claseUnicaDesc: 'Happens only once, on a specific date',
    fecha: 'Date',
    seleccionar: 'Select',
    diasSemana: 'Days of the week',
    horaInicio: 'Start',
    fin: 'End',
    duracion: 'Duration',
    alumnoOpcional: 'Student (optional)',
    sinAlumnoEspecifico: 'No specific student',
    importeEuro: 'Amount (€)',
    editarImporte: 'Edit amount',
    introduceImporte: 'Enter the amount',
    confirmarSesion: 'Confirm session',
    seleccionaDia: 'Select at least one day of the week',
    seleccionaFechaUnica: 'Select a date for the one-off class',
    introduceImporteSesion: 'Enter the session amount',
    tarifaGlobalEditable: 'Global rate · editable',
    tarifaAlumnoEditable: 'Student rate · editable',
    horarioTitle: 'Schedule',
    hoy: 'Today',
    dia: 'Day',
    semana: 'Week',
    mes: 'Month',
    anio: 'Year',
    sesionCancelada: 'Session cancelled',
    sesionRealizada: 'Session completed',
    sesionCanceladaDesc: 'This session was marked as not held.',
    sesionRealizadaDesc: 'This session is already recorded as completed.',
    seRealizo: 'It was held',
    noSeDioMarcarCancelada: 'Not held — mark cancelled',
    importeSesion: 'Session amount',
    cobreAhora: 'Paid now',
    pendiente: 'Pending',
    introduceImporteValido: 'Enter a valid amount',
    sesionConfirmadaCobrada: 'Session confirmed and paid',
    sesionConfirmadaPendiente: 'Session confirmed — payment pending',
    sesionRegistradaHoras: 'Session logged — hours added',
    sesionMarcadaCancelada: 'Session marked as cancelled',
    cobrosTitle: 'Payments',
    todoCobrado: 'All paid!',
    totalPendiente: 'Total pending',
    cobrado: 'Paid',
    parcial: 'Partial',
    marcarCobrado: 'Mark as paid',
    dejarPendiente: 'Leave pending',
    detalleCobro: 'Payment details',
    cobroNoEncontrado: 'Payment not found',
    importe: 'Amount',
    estado: 'Status',
    modo: 'Method',
    periodo: 'Period',
    fechaCobro: 'Payment date',
    cobradoParcial: 'Partially paid',
    notas: 'Notes',
    registrarCobroParcial: 'Log partial payment',
    cobroParcialTitle: 'Partial payment',
    importeCobrado: 'Amount paid (€)',
    introduceMonto: 'Enter an amount',
    noPuedeSuperarMonto: 'Cannot exceed the total',
    sesionesEsteMes: 'Sessions this month',
    sinSesionesEsteMes: 'No sessions this month',
    horasExtraTitle: 'Overtime',
    sinFuenteEmpleo: 'No employment source configured.',
    esteMesRegistradas: 'Logged this month',
    importeExtraProyectado: 'Projected overtime pay',
    horasTrabajadasMes: 'Expected salary this month',
    horasContratadasMes: 'Contracted hours this month',
    horasExtraMes: 'Overtime this month',
    extraACobrar: 'Extra to charge',
    sinRegistros: 'No records yet.\nTap + to add overtime.',
    historial: 'History',
    registrarHorasExtra: 'Log overtime',
    horasExtra: 'Overtime',
    sinAlumno: 'No student',
    eliminarRegistro: 'Delete record',
    confirmarEliminarHoraExtra: 'Delete this overtime record?',
    confirmarEliminarSesion:
        'Delete this registered session? Linked charges or overtime entries will also be removed.',
    registroEliminado: 'Record deleted',
    eliminarSesion: 'Delete session',
    confirmarEliminarSesionCalendario:
        'Delete this session from the calendar? It will be permanently removed.',
    sesionEliminada: 'Session deleted',
    ajustesTitle: 'Settings',
    miCuenta: 'My account',
    miPerfil: 'My profile',
    nombreDatosPersonales: 'Name and personal details',
    apariencia: 'Appearance',
    tema: 'Theme',
    sistema: 'System',
    claro: 'Light',
    oscuro: 'Dark',
    idioma: 'Language',
    idiomaApp: 'App language',
    tarifasCondiciones: 'Rates and conditions',
    tarifas: 'Rates',
    tarifaGlobalPorFuente: 'Global and per-source rates',
    datos: 'Data',
    sincronizacion: 'Backup',
    proximamenteBackup: 'Export, import or use Google Drive',
    exportarCopia: 'Export backup',
    importarCopia: 'Import backup',
    exportarDesc: 'Save your data to a file',
    importarDesc: 'Restore data from a file',
    confirmarImportar: 'Import backup? This will replace all current data.',
    exportExitoso: 'Backup exported successfully',
    importExitoso: 'Data imported. Restart the app to apply changes.',
    archivoInvalido: 'The selected file is not a valid backup',
    conectarDrive: 'Connect to Google Drive',
    desconectarDrive: 'Disconnect account',
    subirDrive: 'Upload to Google Drive',
    restaurarDrive: 'Restore from Google Drive',
    ultimaCopia: 'Last backup',
    sinCopiaPrevia: 'No previous backup',
    backupDriveExitoso: 'Backup uploaded to Google Drive',
    restaurarDriveExitoso: 'Data restored from Google Drive. Restart the app.',
    confirmarRestaurarDrive:
        'Restore from Google Drive? This will replace all current data.',
    copiaLocal: 'Local backup',
    googleDrive: 'Google Drive',
    copiaAutomatica: 'Automatic backup',
    copiaAutomaticaDesc: 'Schedule a daily backup at your chosen time',
    horaCopia: 'Backup time',
    tipoCopia: 'Backup type',
    tipoLocal: 'Local',
    ultimaCopiaAuto: 'Last automatic backup',
    copiaActivada: 'Automatic backup enabled',
    copiaDesactivada: 'Automatic backup disabled',
    driveNecesitaConexion: 'Connect your Google Drive account first',
    ubicacionCopia: 'Backup location',
    rutaCopiada: 'Path copied to clipboard',
    compartirCopia: 'Share backup file',
    sinCopiaLocal: 'No local backup yet',
    versionInfo:
        'Teacher Finance v1.0.0\nOffline-first — your data always with you',
    nombre: 'Name',
    tuNombre: 'Your name',
    preferencias: 'Preferences',
    moneda: 'Currency',
    masOpcionesProximamente: 'More options coming soon',
    perfilActualizado: 'Profile updated',
    tarifasTitle: 'Rates',
    comoFunciona: 'How does it work?',
    jerarquiaTarifas:
        '1. Student rate (if set)\n2. Source rate\n3. Global rate (fallback)',
    tarifaGlobal: 'Global rate',
    tarifaPorAlumno: 'Per-student rate',
    sinAlumnosRegistrados: 'No students registered yet.',
    tarifaGlobalGuardada: 'Global rate saved',
    introduceNumeroValido: 'Enter a valid number',
    porHora: '/h',
    tarifaDe: 'Rate for',
    ingresosMes: 'Monthly income',
    horas: 'Hours',
    todoAlDia: 'All up to date',
    cobro: 'payment',
    noAcademiaConfigurada: 'No academy configured',
    sinAlumnosAcademia: 'No students in this academy',
    sinConfiguracionEmpleo: 'No employment configuration',
    noEmpleoConfigurada: 'No employment source configured',
    noParticularConfigurada: 'No private source configured',
    sinAlumnosParticulares: 'No private students yet',
    porSesionEfectivo: '/session · Cash',
    porSesionMin: '/session',
    alumno: 'Student',
    deCadaMes: 'of each month',
    actividad: 'Activity',
    menos: 'Less',
    mas: 'More',
    sinClasesEsteDia: 'No classes this day',
    clasesDeHoy: 'Today\'s classes',
    sesion: 'session',
    sesiones: 'sessions',
    diasAbreviados: 'M,T,W,T,F,S,S',
    queOcurrioSesion: 'What happened with this session?',
    queSesionFue: 'Which session was it?',
    cuandoCobras: 'When do you get paid?',
    olvidasteContrasena: 'Forgot your password?',
    maxLabel: 'Max.',
    notificaciones: 'Notifications',
    recordatorioClases: 'Reminder before each class',
    minutosAntes: 'min before',
    notificacionesActivadas: 'Notifications enabled',
    notificacionesDesactivadas: 'Notifications disabled',
  );

  // ═══════════════════════════════════════════════════════════════════
  // ITALIANO
  // ═══════════════════════════════════════════════════════════════════
  static const _it = AppLocalizations._(
    appName: 'Teacher Finance',
    navInicio: 'Home',
    navFuentes: 'Fonti',
    navHorario: 'Orario',
    navAlumnos: 'Studenti',
    navCobros: 'Pagamenti',
    guardar: 'Salva',
    cancelar: 'Annulla',
    eliminar: 'Elimina',
    editar: 'Modifica',
    confirmar: 'Conferma',
    aceptar: 'Accetta',
    si: 'Sì',
    no: 'No',
    volver: 'Indietro',
    cerrar: 'Chiudi',
    copiar: 'Copia',
    ver: 'Vedi',
    cargando: 'Caricamento...',
    sinDatos: 'Nessun dato',
    requerido: 'Obbligatorio',
    numeroInvalido: 'Numero non valido',
    errorGenerico: 'Si è verificato un errore',
    loginTitle: 'Teacher Finance',
    loginSubtitleCreate: 'Crea le tue credenziali di accesso',
    loginSubtitleAccess: 'Accedi al tuo account',
    usuario: 'Utente',
    contrasena: 'Password',
    entrar: 'Accedi',
    crearAcceso: 'Crea accesso',
    credencialesIncorrectas: 'Utente o password errati',
    accederCredenciales: 'Visualizza credenziali',
    mostrarCredenciales:
        'Verranno mostrate le credenziali salvate. Continuare?',
    noHayCredenciales: 'Nessuna credenziale salvata',
    tusCredenciales: 'Le tue credenziali',
    mostrarContrasena: 'Mostra password',
    ocultarContrasena: 'Nascondi',
    minCaracteres: 'Minimo 4 caratteri',
    onboardingTitle: 'Benvenuto su Teacher Finance!',
    onboardingSubtitle:
        'Gestisci le tue lezioni, ore e pagamenti dal cellulare.',
    empezar: 'Inizia',
    configuraPerfil: 'Configura il tuo profilo',
    monedaRegion: 'Valuta e regione',
    dashboardTitle: 'Home',
    resumenMes: 'Riepilogo del mese',
    ingresosTotales: 'Entrate totali',
    horasTotales: 'Ore totali',
    cobrosPendientes: 'Pagamenti in sospeso',
    porFuente: 'Per fonte',
    registrarSesion: 'Registra sessione',
    fuentesTitle: 'Fonti di reddito',
    sinFuentes: 'Nessuna fonte di reddito',
    creaUnaParaEmpezar: 'Creane una per iniziare',
    nuevaFuente: 'Nuova fonte',
    editarFuente: 'Modifica fonte',
    nombreFuente: 'Nome della fonte',
    nombreRequerido: 'Nome obbligatorio',
    tipoFuente: 'Tipo di fonte',
    empleo: 'Impiego',
    academia: 'Accademia',
    particular: 'Privato',
    colorIdentificativo: 'Colore identificativo',
    eligeColor: 'Scegli un colore',
    eliminarFuente: 'Elimina fonte',
    confirmarEliminarFuente:
        'Verranno eliminati anche tutti gli studenti, le sessioni e i pagamenti associati a questa fonte. Questa azione non può essere annullata.',
    errorAlGuardar: 'Errore nel salvataggio',
    errorAlEliminar: 'Errore nell\'eliminazione',
    configuracionEmpleo: 'Configurazione impiego',
    salarioBase: 'Stipendio base',
    salarioBaseMensual: 'Stipendio base mensile (€)',
    horasSemanalesContratadas: 'Ore settimanali contrattualizzate',
    tarifaHoraExtra: 'Tariffa straordinario',
    diaCobro: 'Giorno di paga',
    diaCadaMes: 'di ogni mese',
    configuracionContrato: 'Dettagli contratto',
    alumnosTitle: 'Studenti',
    nuevoAlumno: 'Nuovo studente',
    editarAlumno: 'Modifica studente',
    sinAlumnos: 'Nessuno studente registrato',
    sinAlumnosEnFuente: 'Nessuno studente in questa fonte',
    alumnoNoEncontrado: 'Studente non trovato',
    nombreAlumno: 'Nome dello studente',
    fuenteIngreso: 'Fonte di reddito',
    seleccionaFuente: 'Seleziona una fonte',
    tarifaPorHora: 'Tariffa oraria (€/h)',
    tarifaRequerida: 'Tariffa obbligatoria',
    duracionDefecto: 'Durata predefinita',
    notasOpcional: 'Note (facoltativo)',
    telefonoObservaciones: 'Telefono, osservazioni...',
    eliminarAlumno: 'Elimina studente',
    confirmarEliminarAlumno:
        'Eliminare questo studente? Le sessioni registrate saranno conservate.',
    anadirAlumno: 'Aggiungi studente',
    traspasarAlumno: 'Trasferisci studente',
    traspasar: 'Trasferisci',
    sesionesMantenidas:
        'Le sessioni precedenti manterranno la fonte originale.',
    alumnoTraspasado: 'Studente trasferito',
    noHayOtrasFuentes: 'Nessuna altra fonte disponibile',
    nuevaFuenteLabel: 'Nuova fonte',
    sesionesTitle: 'Sessioni',
    nuevaSesionRecurrente: 'Nuova sessione ricorrente',
    editarSesionRecurrente: 'Modifica sessione ricorrente',
    claseUnica: 'Lezione singola',
    claseUnicaDesc: 'Si tiene solo una volta, in una data specifica',
    fecha: 'Data',
    seleccionar: 'Seleziona',
    diasSemana: 'Giorni della settimana',
    horaInicio: 'Inizio',
    fin: 'Fine',
    duracion: 'Durata',
    alumnoOpcional: 'Studente (facoltativo)',
    sinAlumnoEspecifico: 'Nessuno studente specifico',
    importeEuro: 'Importo (€)',
    editarImporte: 'Modifica importo',
    introduceImporte: 'Inserisci l\'importo',
    confirmarSesion: 'Conferma sessione',
    seleccionaDia: 'Seleziona almeno un giorno della settimana',
    seleccionaFechaUnica: 'Seleziona una data per la lezione singola',
    introduceImporteSesion: 'Inserisci l\'importo della sessione',
    tarifaGlobalEditable: 'Tariffa globale · modificabile',
    tarifaAlumnoEditable: 'Tariffa studente · modificabile',
    horarioTitle: 'Orario',
    hoy: 'Oggi',
    dia: 'Giorno',
    semana: 'Settimana',
    mes: 'Mese',
    anio: 'Anno',
    sesionCancelada: 'Sessione annullata',
    sesionRealizada: 'Sessione completata',
    sesionCanceladaDesc: 'Questa sessione è stata segnata come non svolta.',
    sesionRealizadaDesc: 'Questa sessione è già registrata come completata.',
    seRealizo: 'Si è svolta',
    noSeDioMarcarCancelada: 'Non svolta — segna annullata',
    importeSesion: 'Importo della sessione',
    cobreAhora: 'Pagato ora',
    pendiente: 'In sospeso',
    introduceImporteValido: 'Inserisci un importo valido',
    sesionConfirmadaCobrada: 'Sessione confermata e pagata',
    sesionConfirmadaPendiente: 'Sessione confermata — pagamento in sospeso',
    sesionRegistradaHoras: 'Sessione registrata — ore aggiunte',
    sesionMarcadaCancelada: 'Sessione segnata come annullata',
    cobrosTitle: 'Pagamenti',
    todoCobrado: 'Tutto pagato!',
    totalPendiente: 'Totale in sospeso',
    cobrado: 'Pagato',
    parcial: 'Parziale',
    marcarCobrado: 'Segna come pagato',
    dejarPendiente: 'Lascia in sospeso',
    detalleCobro: 'Dettaglio pagamento',
    cobroNoEncontrado: 'Pagamento non trovato',
    importe: 'Importo',
    estado: 'Stato',
    modo: 'Metodo',
    periodo: 'Periodo',
    fechaCobro: 'Data pagamento',
    cobradoParcial: 'Pagato parzialmente',
    notas: 'Note',
    registrarCobroParcial: 'Registra pagamento parziale',
    cobroParcialTitle: 'Pagamento parziale',
    importeCobrado: 'Importo pagato (€)',
    introduceMonto: 'Inserisci un importo',
    noPuedeSuperarMonto: 'Non può superare il totale',
    sesionesEsteMes: 'Sessioni questo mese',
    sinSesionesEsteMes: 'Nessuna sessione questo mese',
    horasExtraTitle: 'Straordinari',
    sinFuenteEmpleo: 'Nessuna fonte di impiego configurata.',
    esteMesRegistradas: 'Registrate questo mese',
    importeExtraProyectado: 'Importo straordinario previsto',
    horasTrabajadasMes: 'Stipendio previsto questo mese',
    horasContratadasMes: 'Ore contrattuali questo mese',
    horasExtraMes: 'Straordinari questo mese',
    extraACobrar: 'Extra da riscuotere',
    sinRegistros:
        'Nessun registro ancora.\nPremi + per aggiungere straordinari.',
    historial: 'Cronologia',
    registrarHorasExtra: 'Registra straordinario',
    horasExtra: 'Straordinari',
    sinAlumno: 'Nessuno studente',
    eliminarRegistro: 'Elimina registro',
    confirmarEliminarHoraExtra: 'Eliminare questo registro di straordinari?',
    confirmarEliminarSesion:
        'Eliminare questa sessione registrata? Verranno rimossi anche gli addebiti o gli straordinari collegati.',
    registroEliminado: 'Registro eliminato',
    eliminarSesion: 'Elimina sessione',
    confirmarEliminarSesionCalendario:
        'Eliminare questa sessione dal calendario? Verrà rimossa permanentemente.',
    sesionEliminada: 'Sessione eliminata',
    ajustesTitle: 'Impostazioni',
    miCuenta: 'Il mio account',
    miPerfil: 'Il mio profilo',
    nombreDatosPersonales: 'Nome e dati personali',
    apariencia: 'Aspetto',
    tema: 'Tema',
    sistema: 'Sistema',
    claro: 'Chiaro',
    oscuro: 'Scuro',
    idioma: 'Lingua',
    idiomaApp: 'Lingua dell\'app',
    tarifasCondiciones: 'Tariffe e condizioni',
    tarifas: 'Tariffe',
    tarifaGlobalPorFuente: 'Tariffa globale e per fonte',
    datos: 'Dati',
    sincronizacion: 'Backup',
    proximamenteBackup: 'Esporta, importa o usa Google Drive',
    exportarCopia: 'Esporta backup',
    importarCopia: 'Importa backup',
    exportarDesc: 'Salva i tuoi dati in un file',
    importarDesc: 'Ripristina i dati da un file',
    confirmarImportar:
        'Importare il backup? Questo sostituirà tutti i dati attuali.',
    exportExitoso: 'Backup esportato correttamente',
    importExitoso: 'Dati importati. Riavvia l\'app per applicare le modifiche.',
    archivoInvalido: 'Il file selezionato non è un backup valido',
    conectarDrive: 'Connetti a Google Drive',
    desconectarDrive: 'Disconnetti account',
    subirDrive: 'Carica su Google Drive',
    restaurarDrive: 'Ripristina da Google Drive',
    ultimaCopia: 'Ultimo backup',
    sinCopiaPrevia: 'Nessun backup precedente',
    backupDriveExitoso: 'Backup caricato su Google Drive',
    restaurarDriveExitoso: 'Dati ripristinati da Google Drive. Riavvia l\'app.',
    confirmarRestaurarDrive:
        'Ripristinare da Google Drive? Questo sostituirà tutti i dati attuali.',
    copiaLocal: 'Backup locale',
    googleDrive: 'Google Drive',
    copiaAutomatica: 'Backup automatico',
    copiaAutomaticaDesc:
        'Programma un backup giornaliero all\'ora che preferisci',
    horaCopia: 'Ora del backup',
    tipoCopia: 'Tipo di backup',
    tipoLocal: 'Locale',
    ultimaCopiaAuto: 'Ultimo backup automatico',
    copiaActivada: 'Backup automatico attivato',
    copiaDesactivada: 'Backup automatico disattivato',
    driveNecesitaConexion: 'Collega prima il tuo account Google Drive',
    ubicacionCopia: 'Posizione del backup',
    rutaCopiada: 'Percorso copiato negli appunti',
    compartirCopia: 'Condividi file di backup',
    sinCopiaLocal: 'Nessun backup locale ancora',
    versionInfo:
        'Teacher Finance v1.0.0\nOffline-first — i tuoi dati sempre con te',
    nombre: 'Nome',
    tuNombre: 'Il tuo nome',
    preferencias: 'Preferenze',
    moneda: 'Valuta',
    masOpcionesProximamente: 'Altre opzioni prossimamente',
    perfilActualizado: 'Profilo aggiornato',
    tarifasTitle: 'Tariffe',
    comoFunciona: 'Come funziona?',
    jerarquiaTarifas:
        '1. Tariffa dello studente (se impostata)\n2. Tariffa della fonte\n3. Tariffa globale (fallback)',
    tarifaGlobal: 'Tariffa globale',
    tarifaPorAlumno: 'Tariffa per studente',
    sinAlumnosRegistrados: 'Nessuno studente registrato.',
    tarifaGlobalGuardada: 'Tariffa globale salvata',
    introduceNumeroValido: 'Inserisci un numero valido',
    porHora: '/h',
    tarifaDe: 'Tariffa di',
    ingresosMes: 'Entrate del mese',
    horas: 'Ore',
    todoAlDia: 'Tutto in regola',
    cobro: 'pagamento',
    noAcademiaConfigurada: 'Nessuna accademia configurata',
    sinAlumnosAcademia: 'Nessun alunno in questa accademia',
    sinConfiguracionEmpleo: 'Nessuna configurazione di impiego',
    noEmpleoConfigurada: 'Nessuna fonte di impiego configurata',
    noParticularConfigurada: 'Nessuna fonte privata configurata',
    sinAlumnosParticulares: 'Nessuno studente privato ancora',
    porSesionEfectivo: '/sessione · Contanti',
    porSesionMin: '/sessione',
    alumno: 'Alunno',
    deCadaMes: 'di ogni mese',
    actividad: 'Attività',
    menos: 'Meno',
    mas: 'Più',
    sinClasesEsteDia: 'Nessuna lezione oggi',
    clasesDeHoy: 'Lezioni di oggi',
    sesion: 'sessione',
    sesiones: 'sessioni',
    diasAbreviados: 'L,M,M,G,V,S,D',
    queOcurrioSesion: 'Cosa è successo con questa sessione?',
    queSesionFue: 'Quale sessione era?',
    cuandoCobras: 'Quando incassi?',
    olvidasteContrasena: 'Password dimenticata?',
    maxLabel: 'Max.',
    notificaciones: 'Notifiche',
    recordatorioClases: 'Promemoria prima di ogni lezione',
    minutosAntes: 'min prima',
    notificacionesActivadas: 'Notifiche attivate',
    notificacionesDesactivadas: 'Notifiche disattivate',
  );
}
