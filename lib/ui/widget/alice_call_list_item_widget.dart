import 'package:alice_notification_payload/helper/alice_conversion_helper.dart';
import 'package:alice_notification_payload/model/alice_http_call.dart';
import 'package:alice_notification_payload/model/alice_http_response.dart';
import 'package:alice_notification_payload/utils/alice_constants.dart';
import 'package:flutter/material.dart';

const _endpointMaxLines = 10;
const _serverMaxLines = 5;

class AliceCallListItemWidget extends StatelessWidget {
  final AliceHttpCall call;
  final Function itemClickAction;

  const AliceCallListItemWidget(this.call, this.itemClickAction, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ignore: avoid_dynamic_calls
      onTap: () => itemClickAction(call),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMethodAndEndpointRow(context),
                      const SizedBox(height: 4),
                      _buildServerRow(),
                      const SizedBox(height: 4),
                      _buildStatsRow(),
                    ],
                  ),
                ),
                _buildResponseColumn(context),
              ],
            ),
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildMethodAndEndpointRow(BuildContext context) {
    final textColor = _getEndpointTextColor(context);
    return Row(
      children: [
        Text(
          call.method,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10),
        ),
        Flexible(
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Text(
              call.endpoint,
              maxLines: _endpointMaxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerRow() {
    return Row(
      children: [
        _getSecuredConnectionIcon(call.secure),
        Expanded(
          child: Text(
            call.server,
            overflow: TextOverflow.ellipsis,
            maxLines: _serverMaxLines,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            _formatTime(call.request!.time),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Flexible(
          child: Text(
            AliceConversionHelper.formatTime(call.duration),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Flexible(
          child: Text(
            '${AliceConversionHelper.formatBytes(call.request!.size)} / '
            '${AliceConversionHelper.formatBytes(call.response!.size)}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AliceConstants.grey);
  }

  String _formatTime(DateTime time) {
    return '${formatTimeUnit(time.hour)}:'
        '${formatTimeUnit(time.minute)}:'
        '${formatTimeUnit(time.second)}:'
        '${formatTimeUnit(time.millisecond)}';
  }

  String formatTimeUnit(int timeUnit) {
    return (timeUnit < 10) ? '0$timeUnit' : '$timeUnit';
  }

  Widget _buildResponseColumn(BuildContext context) {
    final widgets = <Widget>[];
    if (call.loading) {
      widgets
        ..add(
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AliceConstants.lightRed),
            ),
          ),
        )
        ..add(
          const SizedBox(
            height: 4,
          ),
        );
    }
    widgets.add(
      Text(
        _getStatus(call.response!),
        style: TextStyle(
          fontSize: 16,
          color: _getStatusTextColor(context),
        ),
      ),
    );
    return SizedBox(
      width: 50,
      child: Column(
        children: widgets,
      ),
    );
  }

  Color? _getStatusTextColor(BuildContext context) {
    final status = call.response!.status;
    if (status == -1) {
      return AliceConstants.red;
    } else if (status! < 200) {
      return Theme.of(context).textTheme.bodyLarge!.color;
    } else if (status >= 200 && status < 300) {
      return AliceConstants.green;
    } else if (status >= 300 && status < 400) {
      return AliceConstants.orange;
    } else if (status >= 400 && status < 600) {
      return AliceConstants.red;
    } else {
      return Theme.of(context).textTheme.bodyLarge!.color;
    }
  }

  Color? _getEndpointTextColor(BuildContext context) {
    if (call.loading) {
      return AliceConstants.grey;
    } else {
      return _getStatusTextColor(context);
    }
  }

  String _getStatus(AliceHttpResponse response) {
    if (response.status == -1) {
      return 'ERR';
    } else if (response.status == 0) {
      return '???';
    } else {
      return '${response.status}';
    }
  }

  Widget _getSecuredConnectionIcon(bool secure) {
    IconData iconData;
    Color iconColor;
    if (secure) {
      iconData = Icons.lock_outline;
      iconColor = AliceConstants.green;
    } else {
      iconData = Icons.lock_open;
      iconColor = AliceConstants.red;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Icon(
        iconData,
        color: iconColor,
        size: 12,
      ),
    );
  }
}
