import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool enabled;

  const LoadingButton({
    Key? key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }
}
