import 'package:flutter/material.dart';
import 'data_sync_service.dart';

/// Widget that displays the current data synchronization status
/// 
/// This widget provides visual feedback to users about the sync state
/// of their data, including online/offline status and sync progress.
class SyncStatusWidget extends StatelessWidget {
  final bool showOnlineStatus;
  final bool showSyncStatus;
  final EdgeInsetsGeometry? padding;

  const SyncStatusWidget({
    super.key,
    this.showOnlineStatus = true,
    this.showSyncStatus = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showOnlineStatus) _buildOnlineStatus(context),
          if (showOnlineStatus && showSyncStatus) const SizedBox(width: 8),
          if (showSyncStatus) _buildSyncStatus(context),
        ],
      ),
    );
  }

  Widget _buildOnlineStatus(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DataSyncService.isOnline,
      builder: (context, isOnline, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              size: 16,
              color: isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSyncStatus(BuildContext context) {
    return ValueListenableBuilder<SyncStatus>(
      valueListenable: DataSyncService.syncStatus,
      builder: (context, syncStatus, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getSyncIcon(syncStatus),
            const SizedBox(width: 4),
            Text(
              _getSyncText(syncStatus),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getSyncColor(syncStatus),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.check_circle_outline, size: 16, color: Colors.grey);
      case SyncStatus.loading:
      case SyncStatus.syncing:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, size: 16, color: Colors.green);
      case SyncStatus.localOnly:
        return const Icon(Icons.cloud_off, size: 16, color: Colors.orange);
      case SyncStatus.error:
        return const Icon(Icons.error_outline, size: 16, color: Colors.red);
    }
  }

  String _getSyncText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.loading:
        return 'Loading...';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.localOnly:
        return 'Local only';
      case SyncStatus.error:
        return 'Sync error';
    }
  }

  Color _getSyncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.loading:
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.localOnly:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
    }
  }
}

/// Compact sync status indicator for use in app bars or small spaces
class CompactSyncStatusWidget extends StatelessWidget {
  const CompactSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DataSyncService.isOnline,
      builder: (context, isOnline, child) {
        return ValueListenableBuilder<SyncStatus>(
          valueListenable: DataSyncService.syncStatus,
          builder: (context, syncStatus, child) {
            return Tooltip(
              message: _getTooltipMessage(isOnline, syncStatus),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(isOnline, syncStatus),
                ),
                child: syncStatus == SyncStatus.syncing || syncStatus == SyncStatus.loading
                    ? const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  String _getTooltipMessage(bool isOnline, SyncStatus syncStatus) {
    final connectionStatus = isOnline ? 'Online' : 'Offline';
    final syncStatusText = _getSyncStatusText(syncStatus);
    return '$connectionStatus • $syncStatusText';
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.loading:
        return 'Loading data';
      case SyncStatus.syncing:
        return 'Syncing data';
      case SyncStatus.synced:
        return 'Data synced';
      case SyncStatus.localOnly:
        return 'Local data only';
      case SyncStatus.error:
        return 'Sync failed';
    }
  }

  Color _getStatusColor(bool isOnline, SyncStatus syncStatus) {
    if (!isOnline) {
      return Colors.orange;
    }

    switch (syncStatus) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.loading:
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.localOnly:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
    }
  }
}

/// Sync status banner that can be shown at the top of screens
class SyncStatusBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const SyncStatusBanner({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DataSyncService.isOnline,
      builder: (context, isOnline, child) {
        return ValueListenableBuilder<SyncStatus>(
          valueListenable: DataSyncService.syncStatus,
          builder: (context, syncStatus, child) {
            // Only show banner for important status updates
            if (_shouldShowBanner(isOnline, syncStatus)) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: _getBannerColor(isOnline, syncStatus),
                child: Row(
                  children: [
                    Icon(
                      _getBannerIcon(isOnline, syncStatus),
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getBannerMessage(isOnline, syncStatus),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (syncStatus == SyncStatus.error && onRetry != null)
                      TextButton(
                        onPressed: onRetry,
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  bool _shouldShowBanner(bool isOnline, SyncStatus syncStatus) {
    return !isOnline || 
           syncStatus == SyncStatus.localOnly || 
           syncStatus == SyncStatus.error;
  }

  Color _getBannerColor(bool isOnline, SyncStatus syncStatus) {
    if (!isOnline || syncStatus == SyncStatus.localOnly) {
      return Colors.orange;
    }
    if (syncStatus == SyncStatus.error) {
      return Colors.red;
    }
    return Colors.blue;
  }

  IconData _getBannerIcon(bool isOnline, SyncStatus syncStatus) {
    if (!isOnline) {
      return Icons.wifi_off;
    }
    if (syncStatus == SyncStatus.localOnly) {
      return Icons.cloud_off;
    }
    if (syncStatus == SyncStatus.error) {
      return Icons.error_outline;
    }
    return Icons.info_outline;
  }

  String _getBannerMessage(bool isOnline, SyncStatus syncStatus) {
    if (!isOnline) {
      return 'You\'re offline. Changes will sync when connection is restored.';
    }
    if (syncStatus == SyncStatus.localOnly) {
      return 'Using local data. Some changes may not be synced.';
    }
    if (syncStatus == SyncStatus.error) {
      return 'Failed to sync your data. Tap retry to try again.';
    }
    return 'Syncing your data...';
  }
}