import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dhikr_item.dart';
import '../state/app_state.dart';
import 'content_review_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.groups});

  final List<DhikrGroup> groups;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/icon/brand_card.jpg', width: 220),
            ),
          ),
          const SizedBox(height: 24),
          Text('التخصيص', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('حجم الخط'),
            subtitle: Slider(
              value: appState.textScale,
              min: 0.8,
              max: 1.6,
              divisions: 8,
              label: appState.textScale.toStringAsFixed(1),
              onChanged: (v) => appState.setTextScale(v),
            ),
          ),
          SwitchListTile(
            title: const Text('المظهر الداكن'),
            value: appState.darkMode,
            onChanged: appState.setDarkMode,
          ),
          SwitchListTile(
            title: const Text('التنبيه اللمسي عند إكمال الذكر'),
            value: appState.haptics,
            onChanged: appState.setHaptics,
          ),
          const Divider(height: 32),
          Text('عن التطبيق والمصادر', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'تم جمع أذكار هذا التطبيق وتصنيفها من مصادر إسلامية معتمدة، وعلى رأسها كتاب '
            '"حصن المسلم من أذكار الكتاب والسنة" للشيخ سعيد بن علي بن وهف القحطاني، '
            'مع التحقق من كل ذكر مقابل مصدره من القرآن الكريم أو كتب السنة (كصحيح البخاري ومسلم '
            'وسنن أبي داود والترمذي والنسائي وابن ماجه ومسند أحمد).\n\n'
            'كل ذكر في التطبيق يعرض مصدره ودرجة ثبوته. لم تُدرج أي صيغة لم يتمكن فريق '
            'العمل من توثيقها بثقة. جميع بياناتك (المفضلة والتقدّم والإعدادات) تُخزَّن على '
            'جهازك فقط، ولا تُرسل إلى أي خادم.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('مراجعة قاعدة المحتوى (للمطورين)'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContentReviewScreen(groups: groups)),
            ),
          ),
        ],
      ),
    );
  }
}
