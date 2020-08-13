import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('About and Copyright',
              style: Theme.of(context).textTheme.headline6),
          Text(''),
          Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam neque turpis, rhoncus non nisl at, suscipit scelerisque ligula. Duis quis fringilla quam. Quisque iaculis, arcu posuere pretium molestie, nulla sem finibus dolor, sed convallis felis nisl in elit. Integer scelerisque diam nibh, eu scelerisque erat ornare eget. Integer volutpat justo massa, id suscipit est vulputate quis. Vestibulum sed diam vitae velit dictum tempor et id diam. Morbi hendrerit sapien at eros fringilla sodales ornare a magna. Sed vestibulum a felis vitae blandit. Donec at lectus eget est pharetra egestas ut nec sapien. Etiam at eros vehicula, vulputate augue quis, maximus leo. In vehicula lacus ac neque congue dictum. Curabitur dignissim ante eu tellus scelerisque, non bibendum libero consequat. Proin eros ipsum, posuere nec ullamcorper in, lacinia vitae elit. Mauris varius est ante, eu suscipit neque sagittis at. Nam consequat ullamcorper tempus. Nullam lacinia turpis ac arcu eleifend, id elementum urna malesuada.'),
          Text(''),
          Text(
              'Nam dignissim, ligula ut rhoncus viverra, velit tortor pretium massa, in interdum sapien arcu vitae nunc. Morbi accumsan lorem felis, sed condimentum est ullamcorper at. Sed vel rhoncus risus. Nullam nisl massa, congue non pellentesque eu, venenatis a mauris. Sed lorem lorem, molestie id aliquam sed, rhoncus et mauris. Nullam et rhoncus augue. Suspendisse potenti. Donec ultrices orci vel est porta maximus. Pellentesque tristique posuere erat, et tempor felis scelerisque sit amet. Pellentesque vel efficitur velit.'),
          Text('Photo credits:'),
          Text(
              '<span>Photo by <a href="https://unsplash.com/@zoltantasi?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Zoltan Tasi</a> on <a href="https://unsplash.com/photos/SHLOAAUEEQ8?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
          Text(
              '<span>Photo by <a href="https://unsplash.com/@adrienolichon?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Adrien Olichon</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
          Text(
              '<span>Photo by <a href="https://unsplash.com/@kocreated?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Mike Ko</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
          Text(
              '<span>Photo by <a href="https://unsplash.com/@augustinewong?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Augustine Wong</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
          Text(
              '<span>Photo by <a href="https://unsplash.com/@anniespratt?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Annie Spratt</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
        ],
      ),
    );
  }
}
