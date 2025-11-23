import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_sec_virtual/models/patient.dart';
import 'dart:async';

import 'package:mobile_sec_virtual/services/patient_service.dart';

class PatientController extends GetxController {
  final PatientService _patientService = PatientService();

  // Observable lists and states
  final RxList<Patient> patients = <Patient>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Pagination
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  String _currentSearch = '';

  // Search
  final TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;

  // Scroll controller
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadPatients();

    // Adicionar listener para scroll infinito
    scrollController.addListener(_onScroll);

    // Adicionar listener para busca
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Listener para mudanças no campo de busca
  void _onSearchChanged() {
    final query = searchController.text;

    // Cancelar timer anterior
    _debounceTimer?.cancel();

    // Se tiver menos de 3 caracteres e não estiver vazio, não faz nada
    if (query.isNotEmpty && query.length < 3) {
      return;
    }

    // Debounce de 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchPatients(query);
    });
  }

  /// Listener para detectar quando chegar ao final da lista
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      // Quando estiver a 200px do final, carregar mais
      if (!isLoadingMore.value && hasMoreData.value && !isSearching.value) {
        loadMorePatients();
      }
    }
  }

  /// Carrega a primeira página de pacientes
  /// [search] - termo de busca (opcional)
  Future<void> loadPatients({String? search}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _currentPage = 0;
      hasMoreData.value = true;
      _currentSearch = search ?? '';

      final result = await _patientService.getPatients(
        page: _currentPage,
        limit: _itemsPerPage,
        searchName: _currentSearch,
      );

      patients.value = result;

      // Se retornou menos itens que o limite, não há mais dados
      if (result.length < _itemsPerPage) {
        hasMoreData.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Erro ao carregar pacientes: $e';
      print('Erro ao carregar pacientes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega mais pacientes (próxima página)
  Future<void> loadMorePatients() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      _currentPage++;

      final result = await _patientService.getPatients(
        page: _currentPage,
        limit: _itemsPerPage,
        searchName: _currentSearch,
      );

      if (result.isEmpty) {
        hasMoreData.value = false;
      } else {
        patients.addAll(result);

        // Se retornou menos itens que o limite, não há mais dados
        if (result.length < _itemsPerPage) {
          hasMoreData.value = false;
        }
      }
    } catch (e) {
      print('Erro ao carregar mais pacientes: $e');
      _currentPage--; // Reverter página em caso de erro
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Busca pacientes por nome (mínimo 3 caracteres)
  Future<void> searchPatients(String query) async {
    searchQuery.value = query;

    // Se tiver menos de 3 caracteres, carrega todos
    if (query.length < 3) {
      if (query.isEmpty) {
        await loadPatients();
      }
      return;
    }

    // Busca com o termo
    isSearching.value = true;
    await loadPatients(search: query);
    isSearching.value = false;
  }

  /// Refresh manual (pull to refresh)
  Future<void> refreshPatients() async {
    searchController.clear();
    searchQuery.value = '';
    _currentSearch = '';
    await loadPatients();
  }
}
