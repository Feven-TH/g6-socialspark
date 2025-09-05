// lib/features/create/presentation/pages/generate_image_page.dart
import 'package:flutter/material.dart';
import 'package:socialspark_app/features/create/data/models/brand_preset.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/create_remote_ds.dart';
import '../../data/models/requests.dart';

class GenerateImagePage extends StatefulWidget {
  const GenerateImagePage({super.key});
  @override
  State<GenerateImagePage> createState() => _GenerateImagePageState();
}

class _GenerateImagePageState extends State<GenerateImagePage> {
  late final CreateRemoteDataSource _ds;
  final _ideaCtrl = TextEditingController(text: "Product shot of caramel macadamia latte");
  final _styles = const ["realistic", "cinematic", "illustration"];
  final _ratios = const ["1:1", "4:5", "16:9", "9:16"];
  String _style = "realistic";
  String _ratio = "1:1";
  String _platform = "instagram";

  bool _loading = false;
  String? _error;
  String? _returnedPrompt; // what the API gives back

  @override
  void initState() {
    super.initState();
    _ds = CreateRemoteDataSource(ApiClient());
  }

  BrandPreset get _brand => BrandPreset(
        name: "SocialSpark Demo",
        colors: ["#003366", "#F9C51C", "#E74C3C"],
        tone: "Playful",
        defaultHashtags: const ["AddisAbebaCafe", "EthiopianCoffee"],
        footerText: "Made with SocialSpark",
      );

  Future<void> _callGenerate() async {
    setState(() { _loading = true; _error = null; _returnedPrompt = null; });
    final text = _ideaCtrl.text.trim();
    if (text.isEmpty) {
      setState(() { _loading = false; _error = "Please enter an idea/prompt"; });
      return;
    }

    try {
      final prompt = await _ds.generateImagePrompt(
        ImageGenerationRequest(
          prompt: text,
          style: _style,
          aspectRatio: _ratio,
          brandPresets: _brand,
          platform: _platform,
        ),
      );
      setState(() { _returnedPrompt = prompt; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Image (Step 1)")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _ideaCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Idea / Prompt",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _style,
                  decoration: const InputDecoration(labelText: "Style", border: OutlineInputBorder()),
                  items: _styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _style = v ?? "realistic"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _ratio,
                  decoration: const InputDecoration(labelText: "Aspect ratio", border: OutlineInputBorder()),
                  items: _ratios.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setState(() => _ratio = v ?? "1:1"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _platform,
            decoration: const InputDecoration(labelText: "Platform", border: OutlineInputBorder()),
            items: const ["instagram", "tiktok"]
                .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => _platform = v ?? "instagram"),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: Text(_loading ? "Generating…" : "Generate Image Prompt"),
              onPressed: _loading ? null : _callGenerate,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_returnedPrompt != null) ...[
            const SizedBox(height: 16),
            const Text("Returned Prompt", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(_returnedPrompt!),
            const SizedBox(height: 8),
            const Text("Next step will be /render/image with {prompt_used, style, aspect_ratio, platform}."),
          ],
        ],
      ),
    );
  }
}
