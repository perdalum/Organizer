BeginPackage["Organizer`"]

CreateOrganizerPalette
UpdateLogNotebooks

Begin["`Private`"]

If[$VersionNumber >= 12.3,
	(* TODO: Once the "WolframVersion" of Organizer is increased to at least 12.3+, update
	         the code to use PersistentSymbol, and remove this Off call. *)
	Off[PersistentValue::obs]
];

(* PersistentValue["CG:Organizer:PaletteObject", "FrontEndSession"] = None; *)

Needs["Organizer`LogNotebookRuntime`"];
Needs["Organizer`Palette`"]

(* This function is meant to be called manually whenever there is a change to the standard
   set of docked cells or StyleDefinitions. *)
UpdateLogNotebooks[] := Module[{nbs, nbObj},
    nbs = FileNames[
        "Log.nb",
        Organizer`Palette`CategoryDirectory[],
        Infinity
    ];

    Scan[
        Function[nbPath,
            nbObj = NotebookOpen[nbPath];

            installLogNotebookDockedCells[nbObj, FileNameSplit[nbPath][[-2]]];
            installLogNotebookStyles[nbObj];
        ],
        nbs
    ]
]


End[]

EndPackage[]
