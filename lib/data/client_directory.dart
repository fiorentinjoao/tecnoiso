/// Display/identity metadata only — a static name → (CNPJ, logo asset)
/// lookup for clients already known to the business. This is NEVER a
/// source of counts: equipment/agenda counts and next-calibration dates
/// must always be computed live from `EquipmentRepository` by grouping on
/// `Equipment.client` (see `lib/data/derivations.dart`). A client with no
/// matching equipment record must never appear on screen just because it
/// has an entry here (D-02, D-03).
library;

class ClientInfo {
  final String cnpj;
  final String logoAsset;

  const ClientInfo({required this.cnpj, required this.logoAsset});
}

/// Placeholder CNPJ shown when a client name is not present in
/// [kClientDirectory].
const String kUnknownClientCnpj = 'CNPJ não cadastrado';

/// Carried over verbatim from the six `_buildClientCard` call sites
/// previously hardcoded in `clients_page.dart`, so the asset paths already
/// declared in `pubspec.yaml` keep resolving.
const Map<String, ClientInfo> kClientDirectory = {
  'Heineken': ClientInfo(
    cnpj: '3.654.xxx/0001-xx',
    logoAsset: 'assets/client_heineken.png',
  ),
  'Coca-Cola': ClientInfo(
    cnpj: '3.654.xxx/0002-xx',
    logoAsset: 'assets/client_coca_cola.webp',
  ),
  'Docol': ClientInfo(
    cnpj: '3.654.xxx/0003-xx',
    logoAsset: 'assets/client_docol.png',
  ),
  'Portos do Paraná': ClientInfo(
    cnpj: '3.654.xxx/0004-xx',
    logoAsset: 'assets/client_portos_parana.png',
  ),
  'Descarpack': ClientInfo(
    cnpj: '3.654.xxx/0005-xx',
    logoAsset: 'assets/client_descarpack.webp',
  ),
  'Porto Itapoa': ClientInfo(
    cnpj: '3.654.xxx/0006-xx',
    logoAsset: 'assets/client_porto_itapoa.png',
  ),
};

ClientInfo? lookupClient(String name) => kClientDirectory[name];
