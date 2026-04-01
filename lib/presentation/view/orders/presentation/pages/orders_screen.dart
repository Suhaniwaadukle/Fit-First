import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/orders/data/models/get_allorders_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        ProviderScope.containerOf(context)
            .read(DiProviders.ordersControllerProvider.notifier)
            .getAllOrders(context);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final ordersState = ref.watch(DiProviders.ordersControllerProvider);
      return Scaffold(
        appBar: CommonAppBar(
          backgroundColor: Colors.transparent,
          title: "Order History",
          titleStyle: Theme.of(context).textTheme.headlineSmall,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.delete_outline, color: Colors.black),
            ),
          ],
          elevation: 0,
        ),
        body: ordersState.isAllOrdersLoading
            ? CommonLoadingWidget()
            : ordersState.getAllOrdersList.data == null ||
                    ordersState.getAllOrdersList.data!.isEmpty ||
                    ordersState.getAllOrdersList.status == "error"
                ? Center(
                    child: Text("No orders found for the user"),
                  )
                : ListView.builder(
                    itemCount: ordersState.getAllOrdersList.data?.length ?? 0,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: ordersState.getAllOrdersList.data?[index] ??
                            AllOrdersData(),
                      );
                    },
                  ),
      );
    });
  }
}

class OrderCard extends ConsumerStatefulWidget {
  final AllOrdersData order;

  const OrderCard({super.key, required this.order});

  @override
  ConsumerState<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<OrderCard> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final isPurchased = widget.order.status == 'Buy';

    return InkWell(
      onTap: _isUpdating ? null : () => _showStatusDialog(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: _isUpdating 
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.order.productImage ?? '',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.productName ?? 'Unknown Product',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.order.productWeight ?? ''} · ${widget.order.productVariant ?? ''}",
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              '\$${widget.order.productDiscountPrice ?? '0'}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.order.productDiscountPrice !=
                              widget.order.productRealPrice)
                            Flexible(
                              flex: 2,
                              child: Text(
                                '\$${widget.order.productRealPrice ?? '0'}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const Spacer(),
                          Flexible(
                            flex: 3,
                            child: Text(
                              widget.order.visitTimestamp != null
                                  ? "${widget.order.visitTimestamp!.day}/${widget.order.visitTimestamp!.month}/${widget.order.visitTimestamp!.year}"
                                  : '',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.order.status ?? ''),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(widget.order.status ?? ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            if (_isUpdating)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog() {
    final statuses = [
      {'value': 'Pending', 'label': 'Pending', 'icon': Icons.schedule},
      {'value': 'Buy', 'label': 'Purchased', 'icon': Icons.check_circle},
      {'value': 'No Purchase', 'label': 'Not Purchased', 'icon': Icons.cancel},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              Text('Update Order Status'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              final isCurrentStatus = widget.order.status == status['value'];
              
              return ListTile(
                leading: Icon(
                  status['icon'] as IconData,
                  color: isCurrentStatus ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  status['label'] as String,
                  style: TextStyle(
                    fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentStatus ? Colors.blue : Colors.black,
                  ),
                ),
                trailing: isCurrentStatus 
                    ? Icon(Icons.radio_button_checked, color: Colors.blue)
                    : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: isCurrentStatus 
                    ? null 
                    : () {
                        Navigator.pop(context);
                        _updateOrderStatus(status['value'] as String);
                      },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final userId = await _getUserId();
      final orderId = widget.order.id ?? '';

      if (userId.isEmpty || orderId.isEmpty) {
        _showErrorMessage('Missing user ID or order ID');
        return;
      }

      final success = await _updateOrderStatusAPI(
        userId: userId,
        orderId: orderId,
        status: newStatus,
      );

      if (success) {
        // Refresh the orders list
        ref.read(DiProviders.ordersControllerProvider.notifier)
            .getAllOrders(context);

        _showSuccessMessage('Order status updated to ${_getStatusText(newStatus)}');
      } else {
        _showErrorMessage('Failed to update order status');
      }
    } catch (e) {
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<bool> _updateOrderStatusAPI({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    final uri = Uri.parse('https://fitfirst.online/Api/updateOrderStatus');

    try {
      print('Updating order status:');
      print('User ID: $userId');
      print('Order ID: $orderId');
      print('New Status: $status');

      final response = await http.post(
        uri,
        body: {
          'userid': userId,
          'order_id': orderId,
          'status': status,
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  Future<String> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id') ?? 
             prefs.getString('userId') ?? 
             prefs.getString('id') ?? 
             widget.order.userid ?? '';
    } catch (e) {
      print('Error getting user ID: $e');
      return widget.order.userid ?? '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Buy':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'No Purchase':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Buy':
        return 'Purchased';
      case 'Pending':
        return 'Pending';
      case 'No Purchase':
        return 'Not Purchased';
      default:
        return status.isNotEmpty ? status : 'Unknown';
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
