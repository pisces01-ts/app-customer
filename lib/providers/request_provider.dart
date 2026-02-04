import 'package:flutter/material.dart';
import '../models/service_request_model.dart';
import '../models/repair_type_model.dart';
import '../models/technician_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class RequestProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<RepairTypeModel> _repairTypes = [];
  List<ServiceRequestModel> _history = [];
  List<TechnicianModel> _nearbyTechnicians = [];
  ServiceRequestModel? _currentRequest;
  bool _isLoading = false;
  String _errorMessage = '';

  List<RepairTypeModel> get repairTypes => _repairTypes;
  List<ServiceRequestModel> get history => _history;
  List<TechnicianModel> get nearbyTechnicians => _nearbyTechnicians;
  ServiceRequestModel? get currentRequest => _currentRequest;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasActiveRequest => _currentRequest != null && _currentRequest!.isActive;

  Future<void> loadRepairTypes() async {
    final response = await _api.get(ApiConfig.getServices);
    
    if (response.success && response.data != null) {
      final dataList = response.data!['data'] as List? ?? [];
      _repairTypes = dataList.map((e) => RepairTypeModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<bool> submitRequest({
    required String problemType,
    required double lat,
    required double lng,
    String? problemDetails,
    String? problemImage,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _api.post(ApiConfig.submitRequest, body: {
      'problem_type': problemType,
      'location_lat': lat,
      'location_lng': lng,
      if (problemDetails != null) 'problem_details': problemDetails,
      if (problemImage != null) 'problem_image': problemImage,
    });

    _isLoading = false;

    if (response.success && response.data != null) {
      final requestId = response.data!['request_id'] ?? response.data!['data']?['request_id'];
      if (requestId != null) {
        await getRequestStatus(requestId);
      }
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<void> getRequestStatus(int requestId) async {
    final response = await _api.get(
      ApiConfig.getRequestStatus,
      queryParams: {'request_id': requestId.toString()},
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'];
      if (data != null) {
        _currentRequest = ServiceRequestModel.fromJson(data);
        notifyListeners();
      }
    }
  }

  Future<void> checkCurrentJob() async {
    final response = await _api.get(ApiConfig.checkCurrentJob);

    if (response.success && response.data != null) {
      final data = response.data!['data'];
      if (data != null && data['has_active_job'] == true) {
        final requestData = data['job'];
        if (requestData != null) {
          _currentRequest = ServiceRequestModel.fromJson(requestData);
        }
      } else {
        _currentRequest = null;
      }
      notifyListeners();
    }
  }

  Future<bool> cancelRequest(int requestId, {String? reason}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.post(ApiConfig.cancelRequest, body: {
      'request_id': requestId,
      if (reason != null) 'reason': reason,
    });

    _isLoading = false;

    if (response.success) {
      _currentRequest = null;
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<void> loadHistory({int page = 1, int limit = 20}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.get(
      ApiConfig.getServiceHistory,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      final dataList = response.data!['data'] as List? ?? [];
      if (page == 1) {
        _history = dataList.map((e) => ServiceRequestModel.fromJson(e)).toList();
      } else {
        _history.addAll(dataList.map((e) => ServiceRequestModel.fromJson(e)));
      }
    }

    notifyListeners();
  }

  Future<void> loadNearbyTechnicians(double lat, double lng, {double radius = 10}) async {
    final response = await _api.get(
      ApiConfig.nearbyTechnicians,
      queryParams: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
      },
    );

    if (response.success && response.data != null) {
      final dataList = response.data!['data'] as List? ?? [];
      _nearbyTechnicians = dataList.map((e) => TechnicianModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int requestId,
    required int rating,
    String? comment,
  }) async {
    final response = await _api.post(ApiConfig.submitReview, body: {
      'request_id': requestId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    });

    if (!response.success) {
      _errorMessage = response.message;
    }

    return response.success;
  }

  void clearCurrentRequest() {
    _currentRequest = null;
    notifyListeners();
  }
}
