/**
 *
 * Binômes:
 * COMPAORE Wendbarka Elisée Rodolphe
 * KORABOU Hiyori Alexandre
 *
 * DOCUMENTATION DU PROJET : CALCULATRICE EPO
 * * 1. Fonctionnement général :
 * L'application est architecturée autour d'un widget 'Stateful' qui gère l'état de l'affichage.
 * Nous avons opté pour une approche par "Parsing" : toute l'opération est saisie sous
 * forme de chaîne de caractères, puis analysée et calculée lors de l'appui sur "=".
 *
 * * 2. Rôle des principales fonctions :
 * - buildButton() : Widget personnalisé qui génère les touches de la calculatrice.
 * Il gère la forme (ronde ou rectangulaire), la couleur et détecte les appuis (GestureDetector).
 * - onButtonPressed() : Cette fonction gère la logique de saisie. Elle ajoute les chiffres
 * et opérateurs à la chaîne 'displayValue' et déclenche les actions spéciales (C, =, +/-).
 * - evaluateExpression() : Le "cerveau" de l'application. Elle utilise le package 'math_expressions'
 * pour transformer la chaîne de caractères en une expression mathématique réelle et
 * calculer le résultat en respectant les priorités opératoires.
 *
 * * 3. Choix d'implémentation pour le bouton % :
 * Le bouton % a été implémenté pour effectuer un calcul de pourcentage, car sur les calculatrices simples, il est plus utilisé que le modulo
 * * 4. Responsivité :
 * L'interface utilise les widgets 'Expanded' et 'Flexible' pour s'adapter automatiquement
 * à toutes les tailles d'écrans des smartphones Android.
 */

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

// Point d'entrée de l'application : Définit le thème et l'écran principal
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // On enlève le bandeau debug pour le rendu
      title: 'Calculatrice',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Variables globales de l'état (State)
  String displayValue = "0";      // Stocke ce que l'utilisateur voit
  String operationDisplay = "";   // Stocke l'historique de l'opération en haut

  // Gestionnaire d'événements lors de l'appui sur un bouton
  void onButtonPressed(String text) {
    setState(() {
      if (text == "C") {
        // Remise à zéro des variables
        displayValue = "0";
        operationDisplay = "";
      } else if (text == "=") {
        // Préparation de l'historique et lancement du calcul
        operationDisplay = "$displayValue =";
        evaluateExpression();
      } else if (text == "+/-") {
        // Gestion du signe négatif en entourant de parenthèses pour le parser
        if (displayValue.startsWith("-")) {
          displayValue = displayValue.substring(1);
        } else {
          displayValue = "-($displayValue)";
        }
      } else {
        // Concaténation des chiffres et opérateurs
        if (displayValue == "0") {
          displayValue = text; // Remplace le 0 initial par le premier chiffre
        } else {
          displayValue += text;
        }
      }
    });
  }

  // Fonction utilisant la librairie externe pour évaluer la chaine de caractère entrée
  void evaluateExpression() {
    try {
      // Nettoyage : On remplace les symboles d'affichage (×, ÷, %) par les symboles informatiques (*, /, /100)
      String finalExpression = displayValue
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      // Analyse syntaxique de la chaîne de caractères
      var p = Parser();
      Expression exp = p.parse(finalExpression);

      // Évaluation numérique de l'expression
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Mise à jour de l'affichage avec le résultat
      setState(() {
        // On vérifie si le résultat est entier (finit par .0) pour l'afficher proprement
        displayValue = eval.toString().endsWith(".0")
            ? eval.toInt().toString()
            : eval.toString();
      });
    } catch (e) {
      // En cas de saisie invalide, on affiche Erreur
      setState(() {
        displayValue = "Erreur";
      });
    }
  }

  // Widget pour construire les boutons
  Widget buildButton(String text, Color buttonColor, Color textColor, [int j=1]) {
    return GestureDetector(
      onTap: () {
        onButtonPressed(text);
      },
      child: Container(
        width: 80,
        height: j==1 ? 80: 180, // j=1 : bouton rond, sinon bouton vertical long
        decoration: BoxDecoration(
          color: buttonColor,
          shape: j == 1 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: j == 1 ? null : BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Section 1 : Écran de visualisation
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight, // Chiffres alignés en bas à droite
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    operationDisplay,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    displayValue,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section 2 : Clavier tactile
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Première ligne : Fonctions et Opérateurs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("C", Colors.grey[850]!, Colors.white, 1),
                    buildButton("%", Colors.grey[850]!, Colors.white),
                    buildButton("÷", Colors.orange, Colors.white),
                    buildButton("×", Colors.orange, Colors.white),
                  ],
                ),
                // Deuxième ligne : Pavé numérique (7-9)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("7", Colors.grey[850]!, Colors.white),
                    buildButton("8", Colors.grey[850]!, Colors.white),
                    buildButton("9", Colors.grey[850]!, Colors.white),
                    buildButton("-", Colors.orange, Colors.white),
                  ],
                ),
                // Troisième ligne : Pavé numérique (4-6)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("4", Colors.grey[850]!, Colors.white),
                    buildButton("5", Colors.grey[850]!, Colors.white),
                    buildButton("6", Colors.grey[850]!, Colors.white),
                    buildButton("+", Colors.orange, Colors.white),
                  ],
                ),

                // Section basse : Mélange de colonnes pour les derniers chiffres et le bouton "="
                Row(
                  children: [
                    Expanded (
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Sous-ligne pour 1, 2, 3
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildButton("1", Colors.grey[850]!, Colors.white),
                              buildButton("2", Colors.grey[850]!, Colors.white),
                              buildButton("3", Colors.grey[850]!, Colors.white),
                            ],
                          ),
                          const SizedBox(height: 40), // Espace vertical entre les deux rangées
                          // Sous-ligne pour +/-, 0, .
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildButton("+/-", Colors.grey[850]!, Colors.white),
                              buildButton("0", Colors.grey[850]!, Colors.white),
                              buildButton(".", Colors.grey[850]!, Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Le bouton "=" s'étire verticalement
                    Flexible (
                      flex: 1,
                      child: buildButton("=", Colors.orange, Colors.white, 0),),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}