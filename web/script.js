/**
 * Script principal pour le démonstrateur par résolution
 * IFT-3000 - Langages de programmation - Hiver 2026
 *
 * Ce script gère l'interface utilisateur du démonstrateur automatique
 * de propositions logiques basé sur la méthode de résolution.
 *
 * Fonctionnalités:
 * - Saisie d'énoncés logiques (zone de texte ou fichier)
 * - Sélection d'énoncés prédéfinis
 * - Affichage des résultats avec rendu LaTeX (MathJax)
 * - Gestion des erreurs avec messages colorés
 *
 * @author IFT-3000
 * @version 1.0.0
 */

"use strict";

/* ==========================================================================
   SECTION 1: RÉFÉRENCES DOM ET CONSTANTES
   ========================================================================== */

/**
 * Éléments DOM principaux de l'interface.
 */
const elements = {
  /** Liste déroulante des énoncés prédéfinis */
  listeEnonces: document.getElementById("lenonce"),
  /** Zone de texte pour la saisie */
  zoneTexte: document.getElementById("enonce"),
  /** Zone d'affichage des messages d'erreur */
  zoneMessage: document.getElementById("msg"),
  /** Zone d'affichage du résultat de la résolution */
  zoneResultat: document.getElementById("target"),
  /** Section conteneur du résultat */
  sectionResultat: document.getElementById("resultat-section"),
  /** Input file caché pour le chargement de fichiers */
  champFichier: document.getElementById("fichier-input"),
};

/** Hauteur minimale de la zone de texte (correspond à rows="1") */
const HAUTEUR_MIN_ZONE_TEXTE = elements.zoneTexte.scrollHeight;

/** Hauteur maximale automatique (environ 10 lignes) */
const HAUTEUR_MAX_ZONE_TEXTE = HAUTEUR_MIN_ZONE_TEXTE * 10;

/* ==========================================================================
   SECTION 2: UTILITAIRES
   ========================================================================== */

/**
 * Vérifie si MathJax est chargé et prêt à être utilisé.
 * @returns {boolean} true si MathJax est disponible
 */
function estMathJaxPret() {
  return typeof MathJax !== "undefined" && MathJax.typesetPromise;
}

/**
 * Vérifie si les fonctions OCaml sont disponibles.
 * @returns {boolean} true si le backend OCaml est chargé
 */
function estBackendPret() {
  return typeof analyser === "function" && typeof generer_trace === "function";
}

/**
 * Effectue le rendu MathJax sur un élément spécifique.
 * Utilise un guard pour éviter les erreurs si MathJax n'est pas chargé.
 *
 * @param {HTMLElement} element - Élément à rendre (optionnel,
 *   tout le document si omis)
 * @returns {Promise} Promise résolue quand le rendu est terminé
 */
function rendreMathJax(element) {
  if (!estMathJaxPret()) {
    return Promise.resolve();
  }
  const cibles = element ? [element] : undefined;
  return MathJax.typesetPromise(cibles).catch((err) =>
    console.error("Erreur MathJax:", err.message),
  );
}

/* ==========================================================================
   SECTION 3: GESTION DE LA ZONE DE TEXTE
   ========================================================================== */

/**
 * Ajuste automatiquement la hauteur de la zone de texte selon son contenu.
 *
 * Comportement:
 * - S'agrandit pour afficher le contenu, jusqu'à HAUTEUR_MAX_ZONE_TEXTE
 * - Rétrécit pour s'adapter au contenu
 * - Ne descend jamais en dessous de HAUTEUR_MIN_ZONE_TEXTE
 */
function ajusterHauteurZoneTexte() {
  // Réinitialiser pour obtenir le scrollHeight correct
  elements.zoneTexte.style.height = "auto";
  const hauteurContenu = elements.zoneTexte.scrollHeight;

  // Calculer la nouvelle hauteur : entre min et max
  const nouvelleHauteur = Math.min(
    Math.max(HAUTEUR_MIN_ZONE_TEXTE, hauteurContenu),
    HAUTEUR_MAX_ZONE_TEXTE,
  );

  elements.zoneTexte.style.height = nouvelleHauteur + "px";
}

/* ==========================================================================
   SECTION 4: GESTION DES ERREURS
   ========================================================================== */

/**
 * Couleurs associées aux types d'erreurs.
 * @type {Object.<string, string>}
 */
const COULEURS_ERREUR = {
  syntaxe: "red",
  non_implante: "orange",
  interne: "red",
  systeme: "red",
};

/**
 * Préfixes associés aux types d'erreurs.
 * @type {Object.<string, string>}
 */
const PREFIXES_ERREUR = {
  syntaxe: "Erreur de syntaxe: ",
  non_implante: "Fonction non implantée: ",
  interne: "Erreur interne: ",
  systeme: "Erreur système: ",
};

/**
 * Affiche un message d'erreur formaté selon son type.
 *
 * @param {string} typeErreur - Type: syntaxe|non_implante|interne|systeme
 * @param {string} message - Message d'erreur à afficher
 */
function afficherErreur(typeErreur, message) {
  const couleur = COULEURS_ERREUR[typeErreur] || "red";
  const prefixe = PREFIXES_ERREUR[typeErreur] || "Erreur: ";

  // Cacher le résultat précédent
  elements.zoneResultat.innerHTML = "";
  cacherResultat();

  // Afficher le message d'erreur avec la bonne couleur
  elements.zoneMessage.style.color = couleur;
  elements.zoneMessage.textContent = prefixe + message;
  elements.zoneMessage.style.visibility = "visible";

  // Rendre le MathJax si nécessaire (pour les formules dans les erreurs)
  rendreMathJax(elements.zoneMessage);
}

/**
 * Affiche la section de résultat.
 */
function afficherResultat() {
  if (elements.sectionResultat) {
    elements.sectionResultat.classList.remove("hidden-section");
  }
}

/**
 * Cache la section de résultat.
 */
function cacherResultat() {
  if (elements.sectionResultat) {
    elements.sectionResultat.classList.add("hidden-section");
  }
}

/**
 * Parse une réponse JSON du backend et traite le résultat.
 *
 * Format attendu:
 * - Succès: { success: true, data: "..." }
 * - Erreur: { success: false, error: { type: "...", message: "..." } }
 *
 * @param {string} reponseJson - Chaîne JSON retournée par le backend
 * @param {Function} [rappelSucces] - Fonction appelée avec data si succès
 * @returns {boolean} true si succès, false sinon
 */
function traiterReponse(reponseJson, rappelSucces) {
  try {
    const reponse = JSON.parse(reponseJson);

    if (reponse.success) {
      if (rappelSucces) {
        rappelSucces(reponse.data);
      }
      return true;
    } else {
      afficherErreur(reponse.error.type, reponse.error.message);
      return false;
    }
  } catch (e) {
    // Fallback si la réponse n'est pas du JSON valide
    console.error("Erreur parsing JSON:", e, "Réponse:", reponseJson);
    afficherErreur("interne", "Réponse invalide du backend");
    return false;
  }
}

/* ==========================================================================
   SECTION 5: LOGIQUE DE RÉSOLUTION
   ========================================================================== */

/**
 * Génère et affiche la trace de résolution pour un énoncé.
 *
 * Appelle la fonction OCaml generer_trace() exportée par js_of_ocaml,
 * puis affiche le résultat LaTeX dans la zone de résultat.
 *
 * @param {string} enonce - Énoncé logique à résoudre
 */
function executerResolution(enonce) {
  // Vérifier que le backend est disponible
  if (!estBackendPret()) {
    afficherErreur(
      "systeme",
      "Le backend OCaml n'est pas encore chargé. Veuillez réessayer.",
    );
    return;
  }

  // Appel à la fonction OCaml (exportée par interface_web.ml)
  const resultat = generer_trace(enonce);

  traiterReponse(resultat, function (donnees) {
    // Afficher le résultat
    elements.zoneResultat.innerHTML =
      '<p style="text-align: left;">' + donnees + "</p>";
    afficherResultat();

    // Cacher le message d'erreur précédent
    elements.zoneMessage.textContent = "";
    elements.zoneMessage.style.visibility = "hidden";

    // Rendre le LaTeX
    rendreMathJax(elements.zoneResultat);
  });
}

/**
 * Action principale: analyse et résout un énoncé.
 *
 * @param {boolean} depuisZoneTexte - true si l'énoncé vient de la
 *   zone de texte, false s'il vient de la liste déroulante
 */
function traiterEnonce(depuisZoneTexte) {
  const valeur = depuisZoneTexte
    ? elements.zoneTexte.value
    : elements.listeEnonces.value;

  // Vérifier que le backend est disponible
  if (!estBackendPret()) {
    afficherErreur(
      "systeme",
      "Le backend OCaml n'est pas encore chargé. Veuillez réessayer.",
    );
    return;
  }

  if (depuisZoneTexte) {
    // Valider d'abord la syntaxe avant de résoudre
    const resultatAnalyse = analyser(valeur);
    traiterReponse(resultatAnalyse, function () {
      // Syntaxe OK, générer la trace
      executerResolution(valeur);
    });
  } else {
    // Énoncé prédéfini: pas besoin de valider
    executerResolution(valeur);
  }
}

/* ==========================================================================
   SECTION 6: GESTIONNAIRES D'ÉVÉNEMENTS
   ========================================================================== */

/**
 * Réinitialise l'interface à son état initial.
 * Appelée au chargement de la page (onload).
 */
function reset() {
  elements.zoneTexte.value = "";
  elements.zoneTexte.style.height = HAUTEUR_MIN_ZONE_TEXTE + "px";
  elements.zoneMessage.textContent = "";
  elements.zoneMessage.style.visibility = "hidden";
  cacherResultat();

  // Retirer la classe qui cache les éléments pendant le chargement
  document.body.classList.remove("initial-hide");
}

/**
 * Gestionnaire du bouton "Ok".
 * Déclenche la résolution si la zone de texte n'est pas vide.
 */
function Ok() {
  if (elements.zoneTexte.value.trim() !== "") {
    traiterEnonce(true);
  } else {
    cacherResultat();
  }
}

/**
 * Gestionnaire du changement de sélection dans la liste déroulante.
 * Copie l'énoncé sélectionné dans la zone de texte et lance la résolution.
 */
function lenonce_change() {
  if (elements.listeEnonces.value !== "aucun") {
    elements.zoneTexte.value = elements.listeEnonces.value;
    ajusterHauteurZoneTexte();
    traiterEnonce(false);
  }
}

/* ==========================================================================
   SECTION 7: ENREGISTREMENT DES ÉVÉNEMENTS
   ========================================================================== */

// Ajustement automatique de la hauteur de la zone de texte
elements.zoneTexte.addEventListener("input", ajusterHauteurZoneTexte);

// Soumission avec Enter (Shift+Enter pour nouvelle ligne)
elements.zoneTexte.addEventListener("keydown", function (evenement) {
  if (evenement.key === "Enter" && !evenement.shiftKey) {
    evenement.preventDefault();
    if (elements.zoneTexte.value.trim() !== "") {
      traiterEnonce(true);
    } else {
      cacherResultat();
    }
  }
});

// Chargement d'un fichier dans la zone de texte
elements.champFichier.addEventListener("change", function (evenement) {
  const fichier = evenement.target.files[0];

  if (!fichier) {
    return;
  }

  const lecteur = new FileReader();

  lecteur.onload = function (e) {
    elements.zoneTexte.value = e.target.result;
    ajusterHauteurZoneTexte();

    // Réinitialiser l'input pour pouvoir recharger le même fichier
    evenement.target.value = "";

    // Toujours exécuter l'analyse pour les fichiers chargés
    // (même vides, le backend affichera l'erreur appropriée)
    traiterEnonce(true);
  };

  lecteur.onerror = function () {
    afficherErreur("systeme", "Erreur lors de la lecture du fichier");
  };

  lecteur.readAsText(fichier);
});

// Rendre MathJax quand l'accordion Référence rapide s'ouvre
const accordionReference = document.getElementById("collapseReference");
if (accordionReference) {
  accordionReference.addEventListener("shown.bs.collapse", function () {
    rendreMathJax(accordionReference);
  });
}

/* ==========================================================================
   SECTION 8: EXPORTATION PDF
   ========================================================================== */
function genererPDF() {
  window.print();
}
