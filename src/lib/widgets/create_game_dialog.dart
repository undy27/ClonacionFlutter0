import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class CreateGameDialog extends StatefulWidget {
  final Function(String nombre, int jugadores, int minRating, int maxRating) onCreate;

  const CreateGameDialog({super.key, required this.onCreate});

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  int _numJugadores = 2;
  RangeValues _ratingRange = const RangeValues(0, 3000);

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.border, 
            width: 3
          ),
          boxShadow: AppTheme.hardShadow,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    "CREAR PARTIDA",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre de la partida
                Text(
                  "Nombre de la partida",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombreController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: "Ej. Partida de Campeones",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Número de jugadores
                Text(
                  "Número de jugadores: $_numJugadores",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [2, 3, 4].map((num) {
                    final isSelected = _numJugadores == num;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _numJugadores = num;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.secondary : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppTheme.darkBorder : AppTheme.border,
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: isSelected ? AppTheme.smallHardShadow : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "$num",
                              style: TextStyle(
                                fontFamily: 'LexendMega',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Rango de Rating
                Text(
                  "Rating: ${_ratingRange.start.round()} - ${_ratingRange.end.round()}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _ratingRange,
                  min: 0,
                  max: 3000,
                  divisions: 30,
                  activeColor: AppTheme.primary,
                  inactiveColor: isDark ? Colors.grey[800] : AppTheme.background,
                  labels: RangeLabels(
                    _ratingRange.start.round().toString(),
                    _ratingRange.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _ratingRange = values;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.border, 
                              width: 2
                            ),
                          ),
                        ),
                        child: Text(
                          "CANCELAR",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: "CREAR",
                        onPressed: () {
                          print('CreateGameDialog: CREAR button pressed');
                          if (_formKey.currentState!.validate()) {
                            print('CreateGameDialog: Form validated, calling onCreate (not awaiting)');
                            // Close dialog immediately, let onCreate handle async work
                            Navigator.pop(context);
                            print('CreateGameDialog: Dialog closed, calling onCreate');
                            widget.onCreate(
                              _nombreController.text,
                              _numJugadores,
                              _ratingRange.start.round(),
                              _ratingRange.end.round(),
                            );
                          } else {
                            print('CreateGameDialog: Form validation failed');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
