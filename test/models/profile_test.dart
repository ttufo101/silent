import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('ProfileExtension', () {
    test('derives label and filename', () {
      const profile = Profile(id: 7);

      expect(profile.realLabel, '7');
      expect(profile.fileName, '7.yaml');
    });
  });

  group('ProfilesExt', () {
    test('gets profile by id', () {
      const profiles = [Profile(id: 1, label: 'A'), Profile(id: 2, label: 'B')];

      expect(profiles.getProfile(2)?.label, 'B');
      expect(profiles.getProfile(3), isNull);
      expect(profiles.getProfile(null), isNull);
    });

    test('optimizes duplicate labels with incremented suffix', () {
      const profiles = [
        Profile(id: 1, label: 'Work'),
        Profile(id: 2, label: 'Work(1)'),
      ];
      const newProfile = Profile(id: 3, label: 'Work');

      expect(profiles.optimizeLabel(newProfile).label, 'Work(2)');
    });
  });

  group('ProfileRuleLinkExt', () {
    test('builds stable key from non-null parts', () {
      const link = ProfileRuleLink(
        profileId: 1,
        ruleId: 2,
        scene: RuleScene.added,
      );
      const globalLink = ProfileRuleLink(ruleId: 3);

      expect(link.key, '1_2_added');
      expect(globalLink.key, '3');
    });
  });
}
