import 'package:flutter_test/flutter_test.dart';
import 'package:led_managementsoftware_app/domain/entities/scene.dart';
import 'package:led_managementsoftware_app/domain/entities/scene_clip.dart';
import 'package:led_managementsoftware_app/domain/enums/interruption_policy.dart';
import 'package:led_managementsoftware_app/domain/enums/return_behavior.dart';
import 'package:led_managementsoftware_app/domain/enums/scene_category.dart';
import 'package:led_managementsoftware_app/features/live_control/domain/interruption_policy_engine.dart';
import 'package:led_managementsoftware_app/features/live_control/domain/rotation_group_manager.dart';
import 'package:led_managementsoftware_app/features/live_control/domain/scene_clip_resolver.dart';

void main() {
  group('Step 6: Scene/Queue Engine Tests', () {
    late InterruptionPolicyEngine interruptionEngine;
    late RotationGroupManager rotationManager;
    late SceneClipResolver clipResolver;

    setUp(() {
      interruptionEngine = InterruptionPolicyEngine();
      rotationManager = RotationGroupManager();
      clipResolver = SceneClipResolver(rotationManager: rotationManager);
    });

    group('InterruptionPolicyEngine', () {
      test('immediate policy allows interruption', () {
        final clip = SceneClip(
          id: 'clip-1',
          sceneId: 'scene-1',
          mediaItemId: 'media-1',
          orderIndex: 0,
          isProtected: false,
          isOverridable: false,
          priority: 0,
          playOnce: false,
          repeatable: true,
          rotationGroup: null,
          interruptionPolicy: InterruptionPolicy.immediate,
          returnBehavior: ReturnBehavior.toPreviousClip,
        );

        final canInterrupt = interruptionEngine.canInterrupt(
          currentClip: clip,
          actionPolicy: InterruptionPolicy.immediate,
          clipCanBeInterrupted: true,
        );

        expect(canInterrupt, isTrue);
      });

      test('protected clip without override blocks interruption', () {
        final clip = SceneClip(
          id: 'clip-2',
          sceneId: 'scene-1',
          mediaItemId: 'media-2',
          orderIndex: 1,
          isProtected: true,
          isOverridable: false,
          priority: 1,
          playOnce: false,
          repeatable: true,
          rotationGroup: null,
          interruptionPolicy: InterruptionPolicy.immediate,
          returnBehavior: ReturnBehavior.toPreviousClip,
        );

        final canInterrupt = interruptionEngine.canInterrupt(
          currentClip: clip,
          actionPolicy: InterruptionPolicy.immediate,
          clipCanBeInterrupted: false,
        );

        expect(canInterrupt, isFalse);
      });

      test('queueEnd policy respects clip protection', () {
        final protectedClip = SceneClip(
          id: 'clip-protected',
          sceneId: 'scene-1',
          mediaItemId: 'media-3',
          orderIndex: 0,
          isProtected: true,
          isOverridable: false,
          priority: 0,
          playOnce: false,
          repeatable: true,
          rotationGroup: null,
          interruptionPolicy: InterruptionPolicy.queueEnd,
          returnBehavior: ReturnBehavior.toPreviousClip,
        );

        final canInterrupt = interruptionEngine.canInterrupt(
          currentClip: protectedClip,
          actionPolicy: InterruptionPolicy.queueEnd,
          clipCanBeInterrupted: true,
        );

        // geschützter Clip mit queueEnd sollte nicht unterbrechen
        expect(canInterrupt, isFalse);
      });

      test('shouldWaitForClipEnd returns true for queueEnd and sceneEnd', () {
        expect(
          interruptionEngine.shouldWaitForClipEnd(InterruptionPolicy.queueEnd),
          isTrue,
        );
        expect(
          interruptionEngine.shouldWaitForClipEnd(InterruptionPolicy.sceneEnd),
          isTrue,
        );
        expect(
          interruptionEngine.shouldWaitForClipEnd(InterruptionPolicy.immediate),
          isFalse,
        );
      });
    });

    group('RotationGroupManager', () {
      test('registers and tracks rotation groups', () {
        rotationManager.registerGroup(
          groupName: 'twoMinHome',
          clipIds: ['clip1', 'clip2', 'clip3', 'clip4'],
        );

        expect(rotationManager.groupCount, equals(1));

        final state = rotationManager.getGroupState('twoMinHome');
        expect(state, isNotNull);
        expect(state!.clipIds.length, equals(4));
      });

      test('nextClipIndex cycles through all clips', () {
        rotationManager.registerGroup(
          groupName: 'rotation1',
          clipIds: ['clip-a', 'clip-b', 'clip-c'],
        );

        // erste runde
        expect(rotationManager.getNextClipIndex('rotation1'), equals(0));
        expect(rotationManager.getNextClipIndex('rotation1'), equals(1));
        expect(rotationManager.getNextClipIndex('rotation1'), equals(2));

        // zweite runde (reset)
        expect(rotationManager.getNextClipIndex('rotation1'), equals(0));
        expect(rotationManager.getNextClipIndex('rotation1'), equals(1));
      });

      test('resetGroup clears played indices', () {
        rotationManager.registerGroup(
          groupName: 'test',
          clipIds: ['c1', 'c2', 'c3'],
        );

        rotationManager.getNextClipIndex('test');
        rotationManager.getNextClipIndex('test');

        final stateBefore = rotationManager.getGroupState('test');
        expect(stateBefore!.playedIndices.length, equals(2));

        rotationManager.resetGroup('test');

        final stateAfter = rotationManager.getGroupState('test');
        expect(stateAfter!.playedIndices.length, equals(0));
      });

      test('progressPercent calculation', () {
        rotationManager.registerGroup(
          groupName: 'progress',
          clipIds: ['c1', 'c2', 'c3', 'c4'],
        );

        rotationManager.getNextClipIndex('progress');
        rotationManager.getNextClipIndex('progress');

        final state = rotationManager.getGroupState('progress');
        expect(state!.progressPercent, equals(50)); // 2 von 4
      });
    });

    group('SceneClipResolver', () {
      test('resolveNextClip advances to next index', () {
        final scene = Scene(
          id: 'scene-test',
          projectId: 'project-1',
          name: 'Testszene',
          category: SceneCategory.preGame,
          isLooping: false,
          isActive: true,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          clips: [
            SceneClip(
              id: 'clip-1',
              sceneId: 'scene-test',
              mediaItemId: 'media-1',
              orderIndex: 0,
              isProtected: false,
              isOverridable: false,
              priority: 0,
              playOnce: false,
              repeatable: true,
              rotationGroup: null,
              interruptionPolicy: InterruptionPolicy.immediate,
              returnBehavior: ReturnBehavior.toPreviousClip,
            ),
            SceneClip(
              id: 'clip-2',
              sceneId: 'scene-test',
              mediaItemId: 'media-2',
              orderIndex: 1,
              isProtected: false,
              isOverridable: false,
              priority: 0,
              playOnce: false,
              repeatable: true,
              rotationGroup: null,
              interruptionPolicy: InterruptionPolicy.immediate,
              returnBehavior: ReturnBehavior.toPreviousClip,
            ),
          ],
        );

        final nextClip = clipResolver.resolveNextClip(
          currentIndex: 0,
          scene: scene,
        );

        expect(nextClip, isNotNull);
        expect(nextClip!.id, equals('clip-2'));
      });

      test('resolveNextClip loops when enabled', () {
        final scene = Scene(
          id: 'scene-loop',
          projectId: 'project-1',
          name: 'Loopszene',
          category: SceneCategory.preGame,
          isLooping: true,
          isActive: true,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          clips: [
            SceneClip(
              id: 'clip-loop-1',
              sceneId: 'scene-loop',
              mediaItemId: 'media-1',
              orderIndex: 0,
              isProtected: false,
              isOverridable: false,
              priority: 0,
              playOnce: false,
              repeatable: true,
              rotationGroup: null,
              interruptionPolicy: InterruptionPolicy.immediate,
              returnBehavior: ReturnBehavior.toPreviousClip,
            ),
            SceneClip(
              id: 'clip-loop-2',
              sceneId: 'scene-loop',
              mediaItemId: 'media-2',
              orderIndex: 1,
              isProtected: false,
              isOverridable: false,
              priority: 0,
              playOnce: false,
              repeatable: true,
              rotationGroup: null,
              interruptionPolicy: InterruptionPolicy.immediate,
              returnBehavior: ReturnBehavior.toPreviousClip,
            ),
          ],
        );

        // am letzten clip, nächster sollte erster sein (loop)
        final nextClip = clipResolver.resolveNextClip(
          currentIndex: 1,
          scene: scene,
        );

        expect(nextClip, isNotNull);
        expect(nextClip!.id, equals('clip-loop-1'));
      });

      test('markClipAsPlayed and playOnce logic', () {
        final clip = SceneClip(
          id: 'clip-once',
          sceneId: 'scene-1',
          mediaItemId: 'media-1',
          orderIndex: 0,
          isProtected: false,
          isOverridable: false,
          priority: 0,
          playOnce: true,
          repeatable: false,
          rotationGroup: null,
          interruptionPolicy: InterruptionPolicy.immediate,
          returnBehavior: ReturnBehavior.toPreviousClip,
        );

        expect(clipResolver.hasClipBeenPlayed(clip.id), isFalse);

        clipResolver.markClipAsPlayed(clip.id);
        expect(clipResolver.hasClipBeenPlayed(clip.id), isTrue);

        clipResolver.resetPlayedClips();
        expect(clipResolver.hasClipBeenPlayed(clip.id), isFalse);
      });
    });
  });
}
