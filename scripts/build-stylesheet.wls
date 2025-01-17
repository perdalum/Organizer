#!/usr/bin/env wolframscript

$pacletDirectory = DirectoryName[$InputFileName, 2];

PacletDirectoryLoad[$pacletDirectory]

Needs["ConnorGray`Organizer`Toolbar`"]

Print["INFO: Building using $InstallationDirectory == ", $InstallationDirectory]

(*========================================================*)
(* Define values used in Notebook stylesheet expression   *)
(*========================================================*)

(* NOTE: Setting an explicit `Background -> White` here is required because CellFrameLabels
         inherit their styling from the parent cell, and we don't want the checkbox cell
		 to have a colored background. *)
createCheckboxCell[] := Cell[
	BoxData @ ToBoxes @ Checkbox[
		Dynamic[
			Or[
				(* Note: Check for the legacy, un-namespaced "TODOCompletedQ" tagging rule. *)
				(* TODO:
					These should only be present in my personal log notebooks; this
				    legacy tagging rule is not part of any shared release of Organizer.
					Once I've cleaned these out of my personal notebooks, this workaround
					should be removed. *)
				TrueQ @ CurrentValue[
					ParentCell@EvaluationCell[],
					{TaggingRules, "TODOCompletedQ"}
				],
				TrueQ @ CurrentValue[
					ParentCell@EvaluationCell[],
					{TaggingRules, "CG:Organizer", "TODOCompletedQ"}
				]
			],
			Function[val, Module[{
				cell
			},
				cell = ParentCell[EvaluationCell[]];

				(* Remove the legacy, un-namespaced "TODOCompletedQ" tagging rule to ensure
				   it isn't ambiguous when compared to the namespaced tagging rule. *)
				(* See TODO above. *)
				SetOptions[cell, TaggingRules -> Replace[
					CurrentValue[cell, TaggingRules],
					{most___, "TODOCompletedQ" -> _, rest___} :> {most, rest}
				]];

				CurrentValue[cell, {TaggingRules, "CG:Organizer", "TODOCompletedQ"}] = val;
			]]
		]
	],
	Background -> White
]

(*====================================*)

todoDefinitions = Sequence[
	TaggingRules -> {"CG:Organizer" -> {"TODOCompletedQ" -> False}},
	LineSpacing -> {0.95, 0},
	CellMargins -> {{66, 0}, {2, 2}},
	CellFrame -> {{2, 0}, {0, 0}},
	CellFrameColor -> GrayLevel[0.7],
	CellFrameMargins -> 5,
	CellFrameLabelMargins -> 3,
	CellFrameLabels -> {
		{createCheckboxCell[], None},
		{None, None}
	}
];

(*
	Parameters: {icon, label, tooltip, action, buttonMethod, buttonDefaultBackground, buttonAccentColor}

	(TemplateBox DisplayFunction's are 'evaluated' by the FrontEnd, whose
	very basic evaluator doesn't not support named Function parameters.)
*)
$iconAndLabelButtonTemplate = Function[
	DynamicModuleBox[{state = "default"},
		TagBox[
			ButtonBox[
				FrameBox[
					GridBox[
						{{
							StyleBox[
								#1,
								GraphicsBoxOptions -> {
									BaseStyle -> Dynamic[
										Switch[state,
											"hovered", White,
											_, #7
										]
									]
								}
							],
							PaneBox[#2]
						}},
						GridBoxAlignment -> {
							"Columns" -> {{Left}},
							"Rows" -> {{Center}}
						}
					],
					BaseStyle -> {
						FontSize -> 10,
						FontWeight -> Automatic,
						FontColor -> Dynamic[Switch[state,
							"hovered", White,
							_, #7
						]]
					},
					FrameMargins -> {{2, 2}, {2, 1}},
					FrameStyle -> Directive[Thickness[1], #7],
					Background -> Dynamic[Switch[state,
						"default",
							#6,
						"hovered",
							RGBColor[1, 0.5, 0],
						"pressed",
							Gray
					]],
					RoundingRadius -> 3
				],
				Appearance -> None,
				ButtonFunction :> #4,
				Method -> #5,
				Evaluator -> Automatic
			],
			EventHandlerTag[{
				"MouseEntered" :> (state = "hovered"),
				"MouseExited" :> (state = "default"),
				{"MouseDown", 1} :> (state = "pressed"),
				{"MouseUp", 1} :> (state = "hovered"),
				PassEventsDown -> True,
				PassEventsUp -> True,
				Method -> "Preemptive"
			}]
		],
		DynamicModuleValues :> {}
	]
]

(*------------------------------------*)

(*
	Parameters: {
		icon, label, tooltip,
		choiceActions, buttonMethod,
		buttonDefaultBackground, buttonAccentColor
	}

	(TemplateBox DisplayFunction's are 'evaluated' by the FrontEnd, whose
	very basic evaluator doesn't not support named Function parameters.)
*)
$iconAndLabelDropdownTemplate = Function[
	DynamicModuleBox[{state = "default"},
		TagBox[
			ActionMenuBox[
				FrameBox[
					GridBox[
						{{
							StyleBox[
								#1,
								GraphicsBoxOptions -> {
									BaseStyle -> Dynamic[
										Switch[state,
											"hovered", White,
											_, #7
										]
									]
								}
							],
							TemplateBox[
								{
									#2,
									"\"\[ThinSpace]\[ThinSpace]\[FilledDownTriangle]\""
								},
								"RowDefault"
							]
						}},
						GridBoxAlignment -> {
							"Columns" -> {{Left}},
							"Rows" -> {{Center}}
						}
					],
					BaseStyle -> {
						FontSize -> 10,
						FontWeight -> Automatic,
						FontColor -> Dynamic[Switch[state,
							"hovered", White,
							_, #7
						]]
					},
					FrameMargins -> {{2, 2}, {2, 1}},
					FrameStyle -> Directive[Thickness[1], #7],
					Background -> Dynamic[Switch[state,
						"default",
							#6,
						"hovered",
							RGBColor[1, 0.5, 0],
						"pressed",
							Gray
					]],
					RoundingRadius -> 3
				],
				#4,
				Appearance -> None,
				Method -> #5,
				Evaluator -> Automatic
			],
			EventHandlerTag[{
				"MouseEntered" :> (state = "hovered"),
				"MouseExited" :> (state = "default"),
				{"MouseDown", 1} :> (state = "pressed"),
				{"MouseUp", 1} :> (state = "hovered"),
				PassEventsDown -> True,
				PassEventsUp -> True,
				Method -> "Preemptive"
			}]
		],
		DynamicModuleValues :> {}
	]
]


(*========================================================*)
(* Create the stylesheet Notebook expression              *)
(*========================================================*)

organizerStylesheetNotebook = Notebook[{
	Cell[StyleData[StyleDefinitions -> "Default.nb"]],

	Cell[StyleData[StyleDefinitions -> "ConnorGray/CellInsertionMenu.nb"]],

	(*================================*)
	(* Override built-in cell styles  *)
	(*================================*)

	Cell[StyleData["Input"],
		StyleKeyMapping -> {
			"/" -> "ConnorGray/CellInsertionMenu",
			"[" -> "TODO",
			"=" -> "WolframAlphaShort",
			"*" -> "Item",
			">" -> "ExternalLanguage"
		}
	],

	(*================================*)
	(* TODO cell styles               *)
	(*================================*)

	Cell[StyleData["TODO", StyleDefinitions -> StyleData["Text"] ],
		todoDefinitions,
		"ReturnCreatesNewCell" -> True,
		(* If the user presses the Tab key or the '*', convert this cell to a
			"TODO:Item" cell. *)
		StyleKeyMapping -> {"Tab" -> "TODO:Item", "*" -> "TODO:Item"}
	],
	Cell[StyleData["TODO:Item", StyleDefinitions -> StyleData["Text"] ],
		(* Override the default TODO cell frame. The gray bar looks weird as part
			of an item. *)
		CellFrame -> {{0, 0}, {0, 0}},

		(* The below rules are taken from the Default.nb stylesheet notebook
			definition for an "Item" cell. *)
		CellDingbat -> StyleBox[
			"\[FilledSmallSquare]",
			Alignment -> Baseline,
			RGBColor[0.8, 0.043, 0.008]
		],
		CellMargins -> {{81, 0}, {2, 2}},
		"ReturnCreatesNewCell" -> True,

		StyleKeyMapping -> {"Tab" -> "TODO:Subitem", "*" -> "TODO:Subitem", "Backspace" -> "TODO"},

		todoDefinitions
	],
	Cell[StyleData["TODO:Subitem", StyleDefinitions -> StyleData["Text"] ],
		(* Override the default TODO cell frame. The gray bar looks weird as part
			of an item. *)
		CellFrame -> {{0, 0}, {0, 0}},

		(* The below rules are taken from the Default.nb stylesheet notebook
			definition for an "Subitem" cell. *)
		CellDingbat -> StyleBox[
			"\[FilledSmallSquare]",
			Alignment -> Baseline,
			RGBColor[0.8, 0.043, 0.008]
		],
		CellMargins -> {{105, 0}, {2, 2}},
		"ReturnCreatesNewCell" -> True,

		StyleKeyMapping -> {"Tab" -> "TODO:Subsubitem", "*" -> "TODO:Subsubitem", "Backspace" -> "TODO:Item"},

		todoDefinitions
	],
	Cell[StyleData["TODO:Subsubitem", StyleDefinitions -> StyleData["Text"] ],
		(* Override the default TODO cell frame. The gray bar looks weird as part
			of an item. *)
		CellFrame -> {{0, 0}, {0, 0}},

		(* The below rules are taken from the Default.nb stylesheet notebook
			definition for an "Subsubitem" cell. *)
		CellDingbat -> StyleBox[
			"\[FilledSmallSquare]",
			Alignment -> Baseline,
			RGBColor[0.6, 0.6, 0.6]
		],
		CellMargins -> {{129, 0}, {2, 2}},
		"ReturnCreatesNewCell" -> True,

		StyleKeyMapping -> {"Backspace" -> "TODO:Subitem"},

		todoDefinitions
	],

	(*===================================*)
	(* Toolbar button TemplateBox styles *)
	(*===================================*)

	Cell[
		StyleData["Organizer:IconAndLabelButtonTemplate"],
		TemplateBoxOptions -> {
			DisplayFunction -> $iconAndLabelButtonTemplate
		}
	],
	Cell[
		StyleData["Organizer:IconAndLabelDropdownTemplate"],
		TemplateBoxOptions -> {
			DisplayFunction -> $iconAndLabelDropdownTemplate
		}
	],

	(*=================================*)
	(* Special link TemplateBox styles *)
	(*=================================*)

	With[{
		icon = ToBoxes @ Show[
			GetIcon["MessageLink"],
			BaseStyle -> Gray,
			ImageSize -> 10
		]
	},
		Cell[
			StyleData["Organizer:EmailLinkTemplate"],
			TemplateBoxOptions -> {
				DisplayFunction -> Function[
					TemplateBox[
						{
							(* GridBox[
								{{
									icon,
									StyleBox[#1, 12]
								}},
								GridBoxAlignment -> {
									"Columns" -> {{Left}},
									"Rows" -> {{Center}}
								}
							], *)
							TemplateBox[
								{StyleBox[#1, 12], icon},
								"Superscript"
							],
							#2
						},
						"HyperlinkURL"
					]
				]
			}
		]
	]
},
	StyleDefinitions -> "PrivateStylesheetFormatting.nb"
]

(*========================================================*)
(* Export the generated stylesheet notebook               *)
(*========================================================*)

$styleSheetTargetFile = FileNameJoin[{
	$pacletDirectory,
	"FrontEnd",
	"StyleSheets",
	"ConnorGray",
	"Organizer.nb"
}]

Export[$styleSheetTargetFile, organizerStylesheetNotebook, "NB"]
