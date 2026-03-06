enum ModuleType { abc, spell, pick, trace, find, drive }

class MenuModule {
  const MenuModule({required this.type, required this.imageName});

  final ModuleType type;
  final String imageName;
}
