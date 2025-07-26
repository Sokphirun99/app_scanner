import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/app_theme.dart';
import '../../pdf_tools/presentation/pdf_tools_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildWelcomeSection(),
          _buildFeaturesGrid(context),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.accentColor,
              ],
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'PDF Tools Pro',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Complete PDF manipulation toolkit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 12),
            Text(
              'Welcome to PDF Tools Pro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your complete solution for PDF manipulation. Merge, split, rotate, compress, and perform 50+ operations on your PDF files with ease.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = _getFeaturesList();
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PDF Operations',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            AnimationLimiter(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildFeatureCard(context, features[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, PDFFeature feature) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => feature.onTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                feature.color.withValues(alpha: 0.1),
                feature.color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature.icon,
                  size: 28,
                  color: feature.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About PDF Tools Pro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Built with Flutter and powered by advanced PDF processing libraries. '
              'Inspired by Stirling PDF, this app brings comprehensive PDF manipulation '
              'to your mobile device with an intuitive interface.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  'Privacy-focused • No cloud uploads',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PDFFeature> _getFeaturesList() {
    return [
      PDFFeature(
        title: 'All PDF Tools',
        description: 'Complete toolkit',
        icon: Icons.home_repair_service,
        color: AppTheme.primaryColor,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
      PDFFeature(
        title: 'Merge PDFs',
        description: 'Combine multiple PDFs',
        icon: Icons.merge,
        color: Colors.blue,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
      PDFFeature(
        title: 'Split PDF',
        description: 'Extract pages',
        icon: Icons.content_cut,
        color: Colors.orange,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
      PDFFeature(
        title: 'Compress PDF',
        description: 'Reduce file size',
        icon: Icons.compress,
        color: Colors.green,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
      PDFFeature(
        title: 'Rotate Pages',
        description: 'Rotate PDF pages',
        icon: Icons.rotate_right,
        color: Colors.purple,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
      PDFFeature(
        title: 'Add Watermark',
        description: 'Brand your PDFs',
        icon: Icons.branding_watermark,
        color: Colors.cyan,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
      PDFFeature(
        title: 'Password Protect',
        description: 'Secure your PDFs',
        icon: Icons.lock,
        color: Colors.red,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
      PDFFeature(
        title: 'Images to PDF',
        description: 'Convert images',
        icon: Icons.image,
        color: Colors.teal,
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDFToolsPage()),
        ),
      ),
    ];
  }
}

class PDFFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Function(BuildContext) onTap;

  const PDFFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
