import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

class CameraComponent extends CameraComponent {
  CameraComponent({required World world}) : super(world: world);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set initial camera position
    position = Vector2.zero();
    zoom = 1.0;
    
    // Enable smooth camera movements
    speed = 1.0;
  }

  void moveTo(Vector2 targetPosition, {double duration = 1.0}) {
    // Smooth camera movement to target position
    // This would be implemented with tweening in a full implementation
    position = targetPosition;
  }

  void zoomTo(double targetZoom, {double duration = 0.5}) {
    // Smooth zoom transition
    zoom = targetZoom.clamp(0.5, 3.0);
  }

  void followComponent(PositionComponent component) {
    // Make camera follow a specific component
    follow(component);
  }

  void stopFollowing() {
    // Stop following any component
    follow(null);
  }
}
