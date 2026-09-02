class SearchBox extends StatelessWidget {
  const SearchBox({
    required this.controller,
    required this.enabled,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: 'Search city, country or region',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: enabled ? onSearch : null,
          tooltip: 'Search weather',
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}