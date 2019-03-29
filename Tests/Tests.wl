(* ::Package:: *)

(* ::Subsection::Closed:: *)
(*Description*)


(* These are unit test for "MeshTools" paclet. 
Each test should normally run fast enough (i.e. < 0.1 second),
so that there can be many of them and the whole procedure doesn't take too long.*)

(* "MeshTools" package must be loaded before running these tests, otherwise testing is aborted. *)
If[
	Not@MemberQ[$Packages,"MeshTools`"],
	Print["Error: Package is not loaded!"];Abort[];
];


(* Currently it is unclear what this line does, it is automatically generated during conversion to .wlt *)
BeginTestSection["Tests"];


(* ::Subsection::Closed:: *)
(*Mesh operations*)


(* ::Subsubsection::Closed:: *)
(*AddMeshMarkers*)


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{2.,0.},{1.,1.},{0.,1.}},
		"MeshElements"->{QuadElement[{{1,2,4,5}}],TriangleElement[{{2,3,4}}]}
	]
	},
	VerificationTest[
		AddMeshMarkers[
			mesh,
			"MeshElementsMarker"->1
		]["MeshElements"]//ElementMarkers,	
		{{1},{1}},
		TestID->"AddMeshMarkers_MeshElements"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{2.,0.},{1.,1.},{0.,1.}},
		"MeshElements"->{QuadElement[{{1,2,4,5}}],TriangleElement[{{2,3,4}}]}
	]
	},
	VerificationTest[
		AddMeshMarkers[
			mesh,
			{"MeshElementsMarker"->1,"BoundaryElementsMarker"->2}
		]["BoundaryElements"]//ElementMarkers,	
		{{2,2,2,2,2}},
		TestID->"AddMeshMarkers_BoundaryElements"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{2.,0.},{1.,1.},{0.,1.}},
		"MeshElements"->{QuadElement[{{1,2,4,5}}],TriangleElement[{{2,3,4}}]}
	]
	},
	VerificationTest[
		AddMeshMarkers[
			mesh,
			{"MeshElementsMarker"->1,"PointElementsMarker"->3}
		]["PointElements"]//ElementMarkers,	
		{{3,3,3,3,3}},
		TestID->"AddMeshMarkers_PointElements"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{2.,0.},{1.,1.},{0.,1.}},
		"MeshElements"->{QuadElement[{{1,2,4,5}}],TriangleElement[{{2,3,4}}]}
	]
	},
	VerificationTest[
		AddMeshMarkers[
			mesh,
			"BadKeyword"->1
		]["MeshElements"]//ElementMarkers,	
		{{0},{0}},
		{AddMeshMarkers::badkey},
		TestID->"AddMeshMarkers_bad-keyword"
	]
];


(* ::Subsubsection::Closed:: *)
(*IdentifyMeshBoundary*)


With[{
	mesh=ToElementMesh[
		Fold[RegionDifference,Rectangle[],{Disk[{1/4,1/4},1/8],Disk[{3/4,3/4},1/6]}],
		"MeshOrder"->1,
		MaxCellMeasure->1
	]},
	VerificationTest[
		IdentifyMeshBoundary[mesh]["BoundaryElementMarkerUnion"],	
		{1,2,3},
		TestID->"IdentifyMeshBoundary_2D-holes"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{0.,1.},{1.,1.},{2.,0.},{4.,0.},{2.,2.},{4.,2.}},
		"MeshElements"->{QuadElement[{{1,2,4,3},{5,6,8,7}},{0,0}]}
	]},
	VerificationTest[
		IdentifyMeshBoundary[mesh]["BoundaryElementMarkerUnion"],	
		{1,2},
		TestID->"IdentifyMeshBoundary_2D-2-quads"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.,0.},{1.,0.,0.},{0.,1.,0.},{1.,1.,0.},{0.,0.,1.},{1.,0.,1.},{0.,1.,1.},{1.,1.,1.},{2.,0.,0.},{4.,0.,0.},{2.,2.,0.},{4.,2.,0.},{2.,0.,2.},{4.,0.,2.},{2.,2.,2.},{4.,2.,2.}},
		"MeshElements"->{HexahedronElement[{{1,2,4,3,5,6,8,7},{9,10,12,11,13,14,16,15}},{0,0}]}
	]},
	VerificationTest[
		IdentifyMeshBoundary[mesh]["BoundaryElementMarkerUnion"],	
		{1,2},
		TestID->"IdentifyMeshBoundary-3D-2-cubes"
	]
];


(* ::Subsubsection::Closed:: *)
(*TransformMesh*)


With[{
	mesh=ToElementMesh[Triangle[],MaxCellMeasure->1,"MeshOrder"->1]
	},
	VerificationTest[
		TransformMesh[mesh,TranslationTransform[{1,0}]],
		(* Default markers and element ordering has changed between versions. *)
		If[
		$VersionNumber>11.1,
		ElementMesh[
			{{1., 0.}, {2., 0.}, {1., 1.}}, 
			{TriangleElement[{{1, 2, 3}}, {0}]}, 
			{LineElement[{{2, 1}, {3, 2}, {1, 3}}, {1, 2, 3}]}, 
			{PointElement[{{1}, {2}, {3}}, {1, 1, 2}]}
		],
		ElementMesh[
			{{1., 0.}, {2., 0.}, {1., 1.}},
			{TriangleElement[{{1, 2, 3}}, {0}]},
			{LineElement[{{3, 2}, {1, 3}, {2, 1}}, {0, 0, 0}]},
			{PointElement[{{1}, {2}, {3}}, {0, 0, 0}]}
		]
		],
		TestID->"TransformMesh_2D-translation-1"
	]
];


With[{
	(* Transforming with identitiy function to avoid marker inconsistencies. *)
	mesh=TransformMesh[
		ToElementMesh[Triangle[],MaxCellMeasure->1,"MeshOrder"->1],
		TranslationTransform[{0,0}]
	],
	tf=ReflectionTransform[{1,0},{0,0}]
	},
	VerificationTest[
		TransformMesh[TransformMesh[mesh,tf],tf],
		mesh,
		TestID->"TransformMesh_2D-default-mesh-double-reflection"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{0.,1.}},
		"MeshElements"->{TriangleElement[{{1,2,3}},{1}]},
		"BoundaryElements"->{LineElement[{{2,1},{3,2},{1,3}},{1,2,3}]},
		"PointElements"->{PointElement[{{1},{2},{3}},{1,2,3}]}
	],
	tf=ReflectionTransform[{1,0},{0,0}]
	},
	VerificationTest[
		TransformMesh[mesh,tf],	
		ElementMesh[
			{{0., 0.}, {-1., 0.}, {0., 1.}}, 
			{TriangleElement[{{2, 1, 3}}, {1}]}, 
			{LineElement[{{1, 2}, {2, 3}, {3, 1}}, {1, 2, 3}]}, 
			{PointElement[{{1}, {2}, {3}}, {1, 2, 3}]}
		],
		TestID->"TransformMesh_2D-reflection-all-element-types"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0., 0.}, {1., 0.}, {0., 1.}, {0.5, 0.}, {0.5, 0.5}, {0.,0.5}},
		"MeshElements"->{TriangleElement[{{1, 2, 3, 4, 5, 6}}]},
		"BoundaryElements"->{LineElement[{{1, 2, 4}, {2, 3, 5}, {3, 1, 6}}, {1, 2, 3}]},
		"PointElements"->  {PointElement[{{1}, {2}, {3}, {4}, {5}, {6}}, {1, 1, 2, 1, 2, 3}]}
	]
	},
	VerificationTest[
		TransformMesh[mesh,ReflectionTransform[{1,0},{0,0}]],	
		ElementMesh[
			{{0., 0.}, {-1., 0.}, {0., 1.}, {-0.5, 0.}, {-0.5, 0.5}, {0., 0.5}},
			{TriangleElement[{{2, 1, 3, 4, 6, 5}}, {0}]},
			{LineElement[{{2, 1, 4}, {3, 2, 5}, {1, 3, 6}}, {1, 2, 3}]},
			{PointElement[{{1}, {2}, {3}, {4}, {5}, {6}}, {1, 1, 2, 1, 2, 3}]}
		],
		TestID->"TransformMesh_2D-reflection-order=2"
	]
];


With[{
	(* Transforming with identitiy function to avoid marker inconsistencies. *)
	mesh=TransformMesh[
		ToElementMesh[Tetrahedron[],MaxCellMeasure->1,"MeshOrder"->1],
		TranslationTransform[{0,0,0}]
	],
	tf=ReflectionTransform[{1,0,0},{0,0,0}]
	},
	VerificationTest[
		TransformMesh[TransformMesh[mesh,tf],tf],
		mesh,
		TestID->"TransformMesh_3D-double-reflection"
	]
];


(* ::Subsubsection::Closed:: *)
(*SelectElements*)


(* Example mesh is defined once as a global symbol, because it is goung to be used in many tests. *)
$mixedMeshExample=ToElementMesh[
	"Coordinates"->{{0.,0.},{1.,0.},{2.,0.},{2.5,0.5},{0.,1.},{1.,1.},{2.,1.},{3.,1.},{2.5,1.5},{0.,2.},{1.,2.},{2.,2.}},
	"MeshElements"->{
		QuadElement[{{1,2,6,5},{2,3,7,6},{5,6,11,10},{6,7,12,11}},{1,1,2,2}],
		TriangleElement[{{3,4,7},{4,8,7},{7,9,12},{7,8,9}},{1,1,2,2}]
	}
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,#2<=1.&]["MeshElements"],	
		{
			TriangleElement[{{3,4,7},{4,8,7}},{1,1}],
			QuadElement[{{1,2,6,5},{2,3,7,6}},{1,1}]
		},
		TestID->"SelectElements_2D-1"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,#1<=1.&]["MeshElements"],	
		{QuadElement[{{1,2,4,3},{3,4,6,5}},{1,2}]},
		TestID->"SelectElements_2D-2"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,#1+1&],	
		$Failed,
		{SelectElements::noelms},
		TestID->"SelectElements_no-elements"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,#1>=0.5&&#2>=0.5&&#3>=0.5&],	
		$Failed,
		{SelectElements::funslots},
		TestID->"SelectElements_wrong-criterion"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,ElementMarker==1]["MeshElements"],
		{TriangleElement[{{3,4,7},{4,8,7}}],QuadElement[{{1,2,6,5},{2,3,7,6}}]},
		TestID->"SelectElements_marker=1"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,ElementMarker==2]["MeshElements"],
		{TriangleElement[{{3,5,8},{3,4,5}}],QuadElement[{{1,2,7,6},{2,3,8,7}}]},
		TestID->"SelectElements_marker=2"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[MeshOrderAlteration[mesh,2],ElementMarker==2]["MeshElements"],
		{
			TriangleElement[{{3,5,8,10,11,12},{3,4,5,9,13,10}}],
			QuadElement[{{1,2,7,6,14,16,17,18},{2,3,8,7,15,12,19,16}}]
		},
		TestID->"SelectElements_marker-MeshOrder->2"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,ElementMarker==0]["MeshElements"],
		{
			TriangleElement[{{3,4,7},{4,8,7},{7,9,12},{7,8,9}},{1,1,2,2}],
			QuadElement[{{1,2,6,5},{2,3,7,6},{5,6,11,10},{6,7,12,11}},{1,1,2,2}]
		},
		{SelectElements::nomark},
		TestID->"SelectElements_non-existent-marker"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,ElementMarker==1||ElementMarker==2]["MeshElements"],
		{
			TriangleElement[{{3,4,7},{4,8,7},{7,9,12},{7,8,9}}],
			QuadElement[{{1,2,6,5},{2,3,7,6},{5,6,11,10},{6,7,12,11}}]
		},
		TestID->"SelectElements_two-markers"
	]
];


With[
	{mesh=$mixedMeshExample},
	VerificationTest[
		SelectElements[mesh,ElementMarker==1.],
		$Failed,
		{SelectElements::intmark},
		TestID->"SelectElements_non-integer-marker"
	]
];


(* ::Subsubsection::Closed:: *)
(*MergeMesh*)


With[{
	m1=AddMeshMarkers[RectangleMesh[1],"MeshElementsMarker"->1],
	m2=AddMeshMarkers[RectangleMesh[1],"MeshElementsMarker"->2]
	},
	VerificationTest[
		MergeMesh[m1,m2]["Coordinates"]//Length,	
		4,
		TestID->"MergeMesh_normal-1"
	]
];


With[{
	m1=AddMeshMarkers[RectangleMesh[1],"MeshElementsMarker"->1],
	m2=AddMeshMarkers[RectangleMesh[1],"MeshElementsMarker"->2]
	},
	VerificationTest[
		MergeMesh[
			{m1,m2},
			"DeleteDuplicateCoordinates"->True
		]["Coordinates"]//Length,	
		4,
		TestID->"MergeMesh_normal-2"
	]
];


With[{
	m1=AddMeshMarkers[RectangleMesh[1],"MeshElementsMarker"->1],
	m2=AddMeshMarkers[RectangleMesh[1],"MeshElementsMarker"->2]
	},
	(* For some weird reason direct comparison of ElementMesh objects doesn't work here. *)
	VerificationTest[
		MergeMesh[
			{m1,m2},
			"DeleteDuplicateCoordinates"->False
		]["Coordinates"]//Length,
		8,
		TestID->"MergeMesh_option-DeleteDuplicateCoordinates"
	]
];


With[{
	m1=RectangleMesh[1],
	m2=MeshOrderAlteration[RectangleMesh[1],2]
	},
	VerificationTest[
		MergeMesh[{m1,m2}],
		$Failed,
		{MergeMesh::order},
		TestID->"MergeMesh_incompatible-order"
	]
];


With[{
	m1=RectangleMesh[1],
	m2=CuboidMesh[1]
	},
	VerificationTest[
		MergeMesh[{m1,m2}],
		$Failed,
		{MergeMesh::dim},
		TestID->"MergeMesh_incompatible-dimensions"
	]
];


(* Check special options that are needed for correct merging of boundary meshes. *)
Module[
	{basic,m1,m2,bMesh,toBoundaryMesh},
	toBoundaryMesh=Function[mesh,
		ToBoundaryMesh[
			"Coordinates"->Append[0.]/@mesh["Coordinates"],
			"BoundaryElements"->mesh["MeshElements"]
		]
	];
	basic=RectangleMesh[1];
	m1=toBoundaryMesh@AddMeshMarkers[basic,"MeshElementsMarker"->1];
	m2=toBoundaryMesh@AddMeshMarkers[basic,"MeshElementsMarker"->2];
	(* ElementMesh is not inert head and sometimes reorders expression 
	therefore option "CheckIntersections" is needed. *)
	VerificationTest[
		MergeMesh[{m1,m2},"CheckIntersections"->False],
		ElementMesh[
			{{0.,0.,0.},{0.,1.,0.},{1.,0.,0.},{1.,1.,0.}},
			Automatic,
			{QuadElement[{{1,3,4,2},{1,3,4,2}},{1,2}]},
			{PointElement[{{1},{2},{3},{4}}]},
			"CheckIntersections"->False
		],
		TestID->"MergeMesh_boundary-mesh-1"
	]
];


(* ::Subsubsection::Closed:: *)
(*ExtrudeMesh*)


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{0.,1.},{1.,0.},{1.,1.},{2.,0.},{2.,1.}},
		"MeshElements"->{QuadElement[{{1,3,4,2},{3,5,6,4}},{1,2}]}
	]
	},
	VerificationTest[
		ExtrudeMesh[mesh,1,1]["Bounds"],	
		{{0.,2.},{0.,1.},{0.,1.}},
		TestID->"ExtrudeMesh_check-bounds"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{0.,1.},{1.,0.},{1.,1.},{2.,0.},{2.,1.}},
		"MeshElements"->{QuadElement[{{1,3,4,2},{3,5,6,4}},{11,22}]}
	]
	},
	VerificationTest[
		ExtrudeMesh[mesh,1,1]["MeshElementMarkerUnion"],	
		{11,22},
		TestID->"ExtrudeMesh_check-markers"
	]
];


With[{
	mesh=ToElementMesh[Rectangle[],MaxCellMeasure->1,"MeshOrder"->2]
	},
	VerificationTest[
		ExtrudeMesh[mesh,1,1],	
		$Failed,
		{ExtrudeMesh::order},
		TestID->"ExtrudeMesh_wrong-MeshOrder"
	]
];


With[{
	mesh=ToElementMesh[Cuboid[],MaxCellMeasure->1,"MeshOrder"->1]
	},
	VerificationTest[
		ExtrudeMesh[mesh,1,1],	
		$Failed,
		{ExtrudeMesh::eltype},
		TestID->"ExtrudeMesh_wrong-EmbeddingDimension"
	]
];


With[{
	mesh=ToElementMesh[Triangle[],MaxCellMeasure->1,"MeshOrder"->1]
	},
	VerificationTest[
		ExtrudeMesh[mesh,1,1],	
		$Failed,
		{ExtrudeMesh::eltype},
		TestID->"ExtrudeMesh_wrong-element-type"
	]
];


(* ::Subsubsection::Closed:: *)
(*QuadToTriangleMesh*)


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0,0},{1,0},{2,1},{0,1},{2,2},{0,2}},
		"MeshElements"->{QuadElement[{{1,2,3,4},{4,3,5,6}},{1,2}]}
	]
	},
	VerificationTest[
		QuadToTriangleMesh[mesh,"SplitDirection"->Automatic]["MeshElements"],	
		{TriangleElement[{{1,2,4},{2,3,4},{4,3,5},{4,5,6}},{1,1,2,2}]},
		TestID->"QuadToTriangleMesh_direction-Automatic"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0,0},{1,0},{2,1},{0,1},{2,2},{0,2}},
		"MeshElements"->{QuadElement[{{1,2,3,4},{4,3,5,6}},{1,2}]}
	]
	},
	VerificationTest[
		QuadToTriangleMesh[mesh,"SplitDirection"->Left]["MeshElements"],	
		{TriangleElement[{{1,2,3},{1,3,4},{4,3,5},{4,5,6}},{1,1,2,2}]},
		TestID->"QuadToTriangleMesh_direction-Left"
	]
];


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0,0},{1,0},{2,1},{0,1},{2,2},{0,2}},
		"MeshElements"->{QuadElement[{{1,2,3,4},{4,3,5,6}},{1,2}]}
	]
	},
	VerificationTest[
		QuadToTriangleMesh[mesh,"SplitDirection"->Right]["MeshElements"],	
		{TriangleElement[{{1,2,4},{2,3,4},{4,3,6},{3,5,6}},{1,1,2,2}]},
		TestID->"QuadToTriangleMesh_direction-Rigth"
	]
];


(* ::Subsubsection::Closed:: *)
(*TriangleToQuadMesh*)


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0., 0.}, {0., 1.}, {1., 0.}, {1., 1.}},
		"MeshElements"->{TriangleElement[{{2, 1, 3}, {3, 4, 2}}]}
	]
	},
	VerificationTest[
		TriangleToQuadMesh[mesh],	
		ElementMesh[
			{{0., 0.}, {0., 1.}, {1., 0.}, {1., 1.}, {0., 0.5}, {0.5,0.}, {1., 0.5}, {0.5, 1.}, {0.5, 0.5}},
			{QuadElement[{{2, 5, 9, 8}, {5, 1, 6, 9}, {9, 6, 3, 7}, {8, 9, 7, 4}}]},
			{LineElement[{{2, 5}, {8, 2}, {5, 1}, {1, 6}, {6, 3}, {3, 7}, {7, 4}, {4, 8}}]}
		],
		TestID->"TriangleToQuadMesh_normal"
	]
];


With[{
	(* A mesh with mixed element types. *)
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{2.,0.},{2.5,0.5},{0.,1.},{1.,1.},{2.,1.},{3.,1.},{2.5,1.5},{0.,2.},{1.,2.},{2.,2.}},
		"MeshElements"->{
			QuadElement[{{1,2,6,5},{2,3,7,6},{5,6,11,10},{6,7,12,11}},{1,1,2,2}],
			TriangleElement[{{3,4,7},{4,8,7},{7,9,12},{7,8,9}},{1,1,2,2}]
		}]
	},
	VerificationTest[
		TriangleToQuadMesh[mesh],	
		$Failed,
		{TriangleToQuadMesh::elmtype},
		TestID->"TriangleToQuadMesh_mixed-element-type"
	]
];


(* ::Subsubsection::Closed:: *)
(*HexToTetrahedronMesh*)


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0,0,0},{1,0,0},{1,1,0},{0,1,0},{0,0,1},{1,0,1},{1,1,1},{0,1,1}},
		"MeshElements"->{HexahedronElement[{{1,2,3,4,5,6,7,8}},{1}]}
	]
	},
	VerificationTest[
		HexToTetrahedronMesh[mesh]["MeshElements"],
		{TetrahedronElement[
			{{1,2,4,5},{2,4,5,8},{2,5,6,8},{2,8,6,3},{2,3,4,8},{3,8,6,7}},
			{1,1,1,1,1,1}
		]},
		TestID->"HexToTetrahedronMesh_1-hex-6-tet"
	]
];


(* ::Subsubsection::Closed:: *)
(*SmoothenMesh*)


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{0.5,0.},{1.,0.},{0.,0.5},{0.4,0.4},{1.,0.5},{0.,1.},{0.5,1.},{1.,1.}},
		"MeshElements"->{QuadElement[{{1,2,5,4},{2,3,6,5},{4,5,8,7},{5,6,9,8}}]}
	]
	},
	VerificationTest[
		SmoothenMesh[mesh]["Coordinates"],
		{{0.,0.},{0.5,0.},{1.,0.},{0.,0.5},{0.5,0.5},{1.,0.5},{0.,1.},{0.5,1.},{1.,1.}},
		TestID->"SmoothenMesh_1-quad"
	]
];


With[{
	mesh=QuadToTriangleMesh[
		ToElementMesh[
			"Coordinates"->{{0.,0.},{0.5,0.},{1.,0.},{0.,0.5},{0.4,0.4},{1.,0.5},{0.,1.},{0.5,1.},{1.,1.}},
			"MeshElements"->{QuadElement[{{1,2,5,4},{2,3,6,5},{4,5,8,7},{5,6,9,8}}]}
		],
		"SplitDirection"->Left
	]
	},
	VerificationTest[
		SmoothenMesh[mesh]["Coordinates"],
		{{0.,0.},{0.5,0.},{1.,0.},{0.,0.5},{0.5,0.5},{1.,0.5},{0.,1.},{0.5,1.},{1.,1.}},
		TestID->"SmoothenMesh_1-triangle"
	]
];


(* ::Subsection::Closed:: *)
(*Mesh measurements*)


(* ::Subsubsection::Closed:: *)
(*MeshElementMeasure*)


(* Length *)
With[{
	mesh=ToElementMesh[
		"Coordinates"->Partition[Subdivide[0,1,3],1],
		"MeshElements"->{LineElement[{{1,2},{2,3},{3,4}}]}
	]
	},
	VerificationTest[
		MeshElementMeasure[mesh],	
		mesh["MeshElementMeasure"],
		TestID->"MeshElementMeasure_line"
	]
];


(* Area *)
With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{1.,1.},{0.,1.}},
		"MeshElements"->{TriangleElement[{{1,2,3},{3,4,1}}]}
	]
	},
	VerificationTest[
		MeshElementMeasure[mesh],	
		mesh["MeshElementMeasure"],
		TestID->"MeshElementMeasure_triangle"
	]
];


(* Area - 2nd order mesh *)
With[{
	mesh=ToElementMesh[
		(* One node is slightly offsed to create curved sides. *)
		"Coordinates"->{{0.,0.},{0.,1.},{1.,0.},{1.,1.},{0.,0.5},{0.5,0.},{0.6,0.6},{1.,0.5},{0.5,1.}},
		"MeshElements"->{TriangleElement[{{2,1,3,5,6,7},{3,4,2,8,9,7}}]}
	]
	},
	VerificationTest[
		MeshElementMeasure[mesh],
		mesh["MeshElementMeasure"],
		SameTest->(RootMeanSquare[Flatten[#1]-Flatten[#2]]<10^-8 &),
		TestID->"MeshElementMeasure_triangle-order=2"
	]
];


(* Area - 2nd order mesh *)
With[{
	mesh=ToElementMesh[
		(* One node is slightly offsed to create curved sides. *)
		"Coordinates"->{{0.,0.},{0.,1.},{1.,0.},{1.,1.},{0.5,0.1},{1.,0.5},{0.5,1.},{0.,0.5}},
		"MeshElements"->{QuadElement[{{1,3,4,2,5,6,7,8}}]}
	]
	},
	VerificationTest[
		MeshElementMeasure[mesh],
		mesh["MeshElementMeasure"],
		SameTest->(RootMeanSquare[Flatten[#1]-Flatten[#2]]<10^-8 &),
		TestID->"MeshElementMeasure_quad-order=2"
	]
];


(* Volume *)
With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.,0.},{0.,0.,1.},{0.,1.,0.},{0.,1.,1.},{1.,0.,0.},{1.,0.,1.},{1.,1.,0.},{1.,1.,1.}},
		"MeshElements"->{TetrahedronElement[{{1,2,8,4},{8,1,6,2},{5,1,6,8},{5,7,1,8},{1,8,7,3},{8,3,1,4}}]}
	]
	},
	VerificationTest[
		MeshElementMeasure[mesh],
		mesh["MeshElementMeasure"],
		TestID->"MeshElementMeasure_tetrahedron"
	]
];


(* Volume *)
With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.,0.},{0.,0.,1.},{0.,1.,0.},{0.,1.,1.},{1.,0.,0.},{1.,0.,1.},{1.,1.,0.},{1.,1.,1.}},
		"MeshElements"->{HexahedronElement[{{1,5,7,3,2,6,8,4}}]}
	]
	},
	VerificationTest[
		MeshElementMeasure[mesh],
		mesh["MeshElementMeasure"],
		TestID->"MeshElementMeasure_hexahedron"
	]
];


With[{
	bmesh=ToBoundaryMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{1.,1.},{0.,1.}},
		"BoundaryElements"->{LineElement[{{1,2},{2,3},{3,4},{4,1}}]}
	]
	},
	VerificationTest[
		MeshElementMeasure[bmesh],
		$Failed,
		{MeshElementMeasure::meshelements},
		TestID->"MeshElementMeasure_boundary-mesh-fail"
	]
];


(* ::Subsubsection::Closed:: *)
(*BoundaryElementMeasure*)


With[{
	mesh=ToElementMesh[
		"Coordinates"->{{0.,0.},{1.,0.},{1.,1.},{0.,1.}},
		"MeshElements"->{TriangleElement[{{1,2,3},{3,4,1}}]}
	]
	},
	VerificationTest[
		BoundaryElementMeasure[mesh],	
		{{1.,1.,1.,1.}},
		TestID->"BoundaryElementMeasure_triangle"
	]
];


With[{
	mesh=ToElementMesh[
		(* One node is slightly offsed to create curved sides. *)
		"Coordinates"->{{0.,0.},{0.,1.},{1.,0.},{1.,1.},{0.,0.5},{0.5,0.},{0.6,0.6},{1.,0.5},{0.5,1.}},
		"MeshElements"->{TriangleElement[{{2,1,3,5,6,7},{3,4,2,8,9,7}}]}
	]
	},
	VerificationTest[
		BoundaryElementMeasure[mesh],
		{{1.,1.,1.,1.}},
		TestID->"BoundaryElementMeasure_triangle-order=2"
	]
];


With[{
	mesh=MeshOrderAlteration[
		ToElementMesh[Disk[],MaxCellMeasure->(1/10)],
		1
	]
	},
	VerificationTest[
		Total@Flatten@BoundaryElementMeasure[mesh],	
		2*Pi,
		SameTest->(Abs[#1-#2]<10^-2&),
		TestID->"BoundaryElementMeasure_disk-order=1"
	]
];


With[{
	mesh=ToElementMesh[Disk[],MaxCellMeasure->(1/10)]
	},
	VerificationTest[
		Total@Flatten@BoundaryElementMeasure[mesh],	
		2*Pi,
		SameTest->(Abs[#1-#2]<10^-5&),
		TestID->"BoundaryElementMeasure_disk-order=2"
	]
];


With[{
	mesh=MeshOrderAlteration[
		ToBoundaryMesh[Sphere[],MaxCellMeasure->(1/10)],
		1
	]
	},
	VerificationTest[
		Total@Flatten@BoundaryElementMeasure[mesh],	
		4*Pi,
		SameTest->(Abs[#1-#2]<10^-1&),
		TestID->"BoundaryElementMeasure_sphere-order=1"
	]
];


(* It seems that even with "MeshOrder"\[Rule]2 sphere doesn't have curved edges and
calculated surface area is the same as "MeshOrder"\[Rule]1. *)
With[{
	mesh=ToBoundaryMesh[Sphere[],MaxCellMeasure->(1/10)]
	},
	VerificationTest[
		Total@Flatten@BoundaryElementMeasure[mesh],	
		4*Pi,
		SameTest->(Abs[#1-#2]<10^-1&),
		TestID->"BoundaryElementMeasure_sphere-order=2"
	]
];


(* ::Subsection::Closed:: *)
(*Mesh visualization*)


With[{
	mesh=ToElementMesh[Rectangle[],MaxCellMeasure->1/10]
	},
	VerificationTest[
		ElementMeshCurvedWireframe[mesh],	
		_Graphics,
		SameTest->MatchQ,
		TestID->"ElementMeshCurvedWireframe-quad"
	]
];


With[{
	mesh=ToElementMesh[Triangle[],MaxCellMeasure->1/10]
	},
	VerificationTest[
		ElementMeshCurvedWireframe[mesh],	
		_Graphics,
		SameTest->MatchQ,
		TestID->"ElementMeshCurvedWireframe-tri"
	]
];


With[{
	mesh=ToElementMesh[Triangle[],MaxCellMeasure->1,"MeshOrder"->1]
	},
	VerificationTest[
		ElementMeshCurvedWireframe[mesh],	
		$Failed,
		{ElementMeshCurvedWireframe::type},
		TestID->"ElementMeshCurvedWireframe-first-order-mesh"
	]
];


(* ::Subsection::Closed:: *)
(*Structured mesh*)


(* Explicitly test node and element ordering in this fundamental function. *)
VerificationTest[
	StructuredMesh[{{{0,0},{2,0}},{{0,1},{2,1}}},{2,1}],
	ElementMesh[
		{{0.,0.},{0.,1.},{1.,0.},{1.,1.},{2.,0.},{2.,1.}},
		{QuadElement[{{1,3,4,2},{3,5,6,4}}]},
		{LineElement[{{1,3},{4,2},{2,1},{3,5},{5,6},{6,4}}]}
	],
	TestID->"StructuredMesh_2D-1"
];


VerificationTest[
	StructuredMesh[{{{0,0,0},{2,0,0}},{{0,1,0},{2,1,0}}},{2,1}],
	ElementMesh[
		{{0.,0.,0.},{0.,1.,0.},{1.,0.,0.},{1.,1.,0.},{2.,0.,0.},{2.,1.,0.}},
		Automatic,
		{QuadElement[{{1,3,4,2},{3,5,6,4}},{1,1}]},
		{PointElement[{{1},{2},{3},{4},{5},{6}}]}
	],
	TestID->"StructuredMesh_3D-1"
];


With[
	{a=3,b=2,c=1},
	VerificationTest[
		StructuredMesh[{
			{{{0,0,0},{a,0,0}},{{0,b,0},{a,b,0}}},
			{{{0,0,c},{a,0,c}},{{0,b,c},{a,b,c}}}
			},
			{3,2,1}
		]["MeshElements"],
		{HexahedronElement[{
			{1,7,9,3,2,8,10,4},
			{3,9,11,5,4,10,12,6},
			{7,13,15,9,8,14,16,10},
			{9,15,17,11,10,16,18,12},
			{13,19,21,15,14,20,22,16},
			{15,21,23,17,16,22,24,18}
		}]},
		TestID->"StructuredMesh_3D-2"
	]
];


(* Function returns unevalueated for non-positive integer division. *)
VerificationTest[
	StructuredMesh[{{{0,0},{2,0}},{{0,1},{2,1}}},{0,1}],
	StructuredMesh[{{{0,0},{2,0}},{{0,1},{2,1}}},{0,1}],
	TestID->"StructuredMesh_non-positive-integer-division"
];


VerificationTest[
	StructuredMesh[{{{0,0},{1,0}},{{0,1},{1,1,2}}},{1,1}],
	$Failed,
	{StructuredMesh::array},
	TestID->"StructuredMesh_non-rectangular-array"
];


VerificationTest[
	StructuredMesh[{{0,0},{1,0},{0,1},{1,1}},{1,1}],
	$Failed,
	{StructuredMesh::array},
	TestID->"StructuredMesh_improper-depth-of-array"
];


(* ::Subsection::Closed:: *)
(*Named meshes 2D*)


(* ::Subsubsection::Closed:: *)
(*RectangleMesh*)


VerificationTest[
	RectangleMesh[2]["Coordinates"]//Sort,
	{{0.,0.},{0.,0.5},{0.,1.},{0.5,0.},{0.5,0.5},{0.5,1.},{1.,0.},{1.,0.5},{1.,1.}},
	TestID->"RectangleMesh_unit-rectangle"
];


VerificationTest[
	RectangleMesh[{1,2},{3,4},{1,2}]["Coordinates"]//Sort,
	{{1.,2.},{1.,3.},{1.,4.},{3.,2.},{3.,3.},{3.,4.}},
	TestID->"RectangleMesh_arbitrary-rectangle"
];


(* ::Subsubsection::Closed:: *)
(*TriangleMesh*)


(* Only coordinates are compared in canonical order because their ordering and 
element ordering should not be important. *)
VerificationTest[
	TriangleMesh[2]["Coordinates"]//Sort,
	{{0,0},{0,1/2},{0,1},{1/3,1/3},{1/2,0},{1/2,1/2},{1,0}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"TriangleMesh_unit-triangle"
];


VerificationTest[
	TriangleMesh[
		{{0,0},{1,1},{2,0}},
		2,
		"MeshElementType"->TriangleElement
	]["Coordinates"]//Sort,
	{{0.,0.},{0.5,0.5},{1.,1.},{1.,0.},{1.5,0.5},{2.,0.}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"TriangleMesh_coordinates"
];


VerificationTest[
	TriangleMesh[
		{{0,0},{1,0},{0,1}},
		1,
		"MeshElementType"->TriangleElement
	]["Coordinates"]//Sort,
	{{0.,0.},{0.,1.},{1.,0.}},
	TestID->"TriangleMesh_triangles-n=1"
];


VerificationTest[
	(* Triangle corners are given in wrong order. *)
	TriangleMesh[
		{{0,0},{0,1},{1,0}},
		2,
		"MeshElementType"->TriangleElement
	]["Coordinates"]//Sort,
	{{0.,0.},{0.,0.5},{0.,1.},{0.5,0.},{0.5,0.5},{1.,0.}},
	TestID->"TriangleMesh_triangles-n=2"
];


VerificationTest[
	TriangleMesh[
		{{0,0},{1,0},{0,1}},
		3,
		"MeshElementType"->TriangleElement
	]["Coordinates"]//Sort,
	{{0,0},{0,1/3},{0,2/3},{0,1},{1/3,0},{1/3,1/3},{1/3,2/3},{2/3,0},{2/3,1/3},{1,0}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"TriangleMesh_triangles-n=3"
];


VerificationTest[
	TriangleMesh[
		{{0,0},{1,0},{0,1}},
		2,
		"MeshElementType"->QuadElement
	]["Coordinates"]//Sort,
	{{0,0},{0,1/2},{0,1},{1/3,1/3},{1/2,0},{1/2,1/2},{1,0}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"TriangleMesh_quads-n=2"
];


VerificationTest[
	TriangleMesh[{{0,0},{1,0},{0,1}},1],
	$Failed,
	{TriangleMesh::quadelms},
	TestID->"TriangleMesh_too-few-elements"
];


VerificationTest[
	TriangleMesh[{{0,0},{1,0},{0,1}},2,"MeshElementType"->"BadValue"],
	$Failed,
	{TriangleMesh::badtype},
	TestID->"TriangleMesh_wrong-option"
];


(* ::Subsubsection::Closed:: *)
(*DiskMesh*)


VerificationTest[
	DiskMesh[1],
	$Failed,
	{DiskMesh::noelems},
	TestID->"DiskMesh_too-few-elements"
];


VerificationTest[
	DiskMesh[2,Method->"unknown"],
	$Failed,
	{DiskMesh::method},
	TestID->"DiskMesh_unknown-method"
];


VerificationTest[
	DiskMesh[2,Method->"Projection"],
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"DiskMesh_method-projection"
];


VerificationTest[
	DiskMesh[2,Method->"Block"],
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"DiskMesh_method-block"
];


(* ::Subsubsection::Closed:: *)
(*AnnulusMesh*)


VerificationTest[
	AnnulusMesh[{4,1}],
	ElementMesh[
		{{1.,0.},{0.5,0.},{0.,1.},{0.,0.5},{-1.,0.},{-0.5,0.},{0.,-1.},{0.,-0.5}},
		{QuadElement[{{1,3,4,2},{3,5,6,4},{5,7,8,6},{7,1,2,8}}]},
		{LineElement[{{1,3},{4,2},{3,5},{6,4},{5,7},{8,6},{7,1},{2,8}}]}
	],
	TestID->"AnnulusMesh_unit-annulus"
];


VerificationTest[
	Length@First@ElementIncidents@(AnnulusMesh[{0,0},{1/2,1},{8,2}]["MeshElements"]),
	16,
	TestID->"AnnulusMesh_arbitrary-annulus-1"
];


VerificationTest[
	AnnulusMesh[{0,0},{1/2,1},{0,Pi},{8,2}]["Bounds"],
	{{-1.,1.},{0.,1.}},
	TestID->"AnnulusMesh_arbitrary-annulus-2"
];


VerificationTest[
	Equal[
		AnnulusMesh[{0,0},{1/2,1},{0,2*Pi},{8,1}],
		AnnulusMesh[{0,0},{1/2,1},{0,3*Pi},{8,1}]
	],
	TestID->"AnnulusMesh_limit-angle-range"
];


VerificationTest[
	AnnulusMesh[{3,1}],
	$Failed,
	{AnnulusMesh::division},
	TestID->"AnnulusMesh_too-few-elements"
];


VerificationTest[
	AnnulusMesh[{0,0},{1/2,1},{0,0},{8,2}],
	$Failed,
	{AnnulusMesh::angle},
	TestID->"AnnulusMesh_coincident-angle-limits"
];


(* ::Subsubsection::Closed:: *)
(*CircularVoidMesh*)


VerificationTest[
	CircularVoidMesh[{0,0},0.2,1,2]["Bounds"],
	{{-0.5,0.5},{-0.5,0.5}},
	TestID->"CircularVoidMesh_arbitrary-void-1"
];


VerificationTest[
	CircularVoidMesh[{0.5,0.5},0.2,1,2]["Bounds"],
	{{0.,1.},{0.,1.}},
	TestID->"CircularVoidMesh_arbitrary-void-2"
];


VerificationTest[
	CircularVoidMesh[{0.,0.},0.6,1,2],
	$Failed,
	{CircularVoidMesh::ratio},
	TestID->"CircularVoidMesh_bad-size-radius-ratio"
];


(* ::Subsection::Closed:: *)
(*Named meshes 3D*)


(* ::Subsubsection::Closed:: *)
(*CuboidMesh*)


VerificationTest[
	Length@First@ElementIncidents[CuboidMesh[2]["MeshElements"]],
	8,
	TestID->"CuboidMesh_unit-cube"
];


VerificationTest[
	CuboidMesh[{0,0,0},{3,2,1},{3,2,1}]["Bounds"],
	{{0.,3.},{0.,2.},{0.,1.}},
	TestID->"CuboidMesh_arbitrary-cuboid"
];


(* ::Subsubsection::Closed:: *)
(*HexahedronMesh*)


VerificationTest[
	Length@First@ElementIncidents[HexahedronMesh[{2,3,4}]["MeshElements"]],
	24,
	TestID->"HexahedronMesh_unit-hexahedron"
];


VerificationTest[
	HexahedronMesh[
		{{0,0,0},{1,0,0},{2,1,0},{1,1,0},{0,0,1},{1,0,1},{2,1,1},{1,1,1}},
		{1,2,2}
	]["Coordinates"]//Length,
	18,
	TestID->"HexahedronMesh_arbitrary-hexahedron"
];


(* The last two points in Hexahedron are switched. *)
VerificationTest[
	HexahedronMesh[
		{{0,0,0},{1,0,0},{2,1,0},{1,1,0},{0,0,1},{1,0,1},{1,1,1},{2,1,1}},
		{1,2,3}
	],
	_ElementMesh,
	{ToElementMesh::femimq,HexahedronMesh::ordering},
	SameTest->MatchQ,
	TestID->"HexahedronMesh_wrong-ordering"
];


(* ::Subsubsection::Closed:: *)
(*TetrahedronMesh*)


(* Only coordinates are compared in canonical order because their ordering and 
element ordering should not be important. *)
VerificationTest[
	TetrahedronMesh[
		{{2,0,0},{2,0,2},{2,2,2},{0,0,2}},
		1,
		"MeshElementType"->TetrahedronElement
	]["Coordinates"]//Sort,
	{{0.,0.,2.},{2.,0.,0.},{2.,0.,2.},{2.,2.,2.}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"TetrahedronMesh_coordinates"
];


VerificationTest[
	TetrahedronMesh[
		{{0,0,0},{1,0,0},{0,1,0},{0,0,1}},
		1,
		"MeshElementType"->TetrahedronElement
	]["Coordinates"]//Sort,
	{{0.,0.,0.},{0.,0.,1.},{0.,1.,0.},{1.,0.,0.}},
	TestID->"TetrahedronMesh_tetrahedron-n=1"
];


VerificationTest[
	TetrahedronMesh[
		{{0,0,0},{1,0,0},{0,1,0},{0,0,1}},
		2,
		"MeshElementType"->TetrahedronElement
	]["Coordinates"]//Sort,
	{{0.,0.,0.},{0.,0.,0.5},{0.,0.,1.},{0.,0.5,0.},{0.,0.5,0.5},{0.,1.,0.},{0.5,0.,0.},{0.5,0.,0.5},{0.5,0.5,0.},{1.,0.,0.}},
	TestID->"TetrahedronMesh_tetrahedron-n=2"
];


VerificationTest[
	TetrahedronMesh[
		{{0,0,0},{1,0,0},{0,1,0},{0,0,1}},
		2,
		"MeshElementType"->HexahedronElement
	]["Coordinates"]//Sort,
	{{0,0,0},{0,0,1/2},{0,0,1},{0,1/3,1/3},{0,1/2,0},{0,1/2,1/2},{0,1,0},{1/4,1/4,1/4},
	{1/3,0,1/3},{1/3,1/3,0},{1/3,1/3,1/3},{1/2,0,0},{1/2,0,1/2},{1/2,1/2,0},{1,0,0}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"TetrahedronMesh_hexahedron-n=2"
];


VerificationTest[
	TetrahedronMesh[1,"MeshElementType"->HexahedronElement],
	$Failed,
	{TetrahedronMesh::hexelms},
	TestID->"TetrahedronMesh_hexahedron-too-few-elements"
];


(* ::Subsubsection::Closed:: *)
(*PrismMesh*)


VerificationTest[
	PrismMesh[{2,2}]["Bounds"],
	{{0.,1.},{0.,1.},{0.,1.}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"PrismMesh_unit-prism"
];


VerificationTest[
	PrismMesh[
		{{1,0,1},{0,0,0},{2,0,0},{1,2,1},{0,2,0},{2,2,0}},
		{2,1}
	]["Coordinates"]//Sort,
	{{0,0,0},{0,2,0},{1/2,0,1/2},{1/2,2,1/2},{1,0,0},{1,2,0},{1,0,1/3},
	{1,2,1/3},{1,0,1},{1,2,1},{3/2,0,1/2},{3/2,2,1/2},{2,0,0},{2,2,0}},
	SameTest->(Norm[Flatten[#1-#2]]<10^-8&),
	TestID->"PrismMesh_arbitrary-prism"
];


(* Wrong number of elements on triangular face edge. *)
VerificationTest[
	PrismMesh[{3,1}],
	$Failed,
	{PrismMesh::noelems},
	TestID->"PrismMesh_wrong-element-specification"
];


(* Prism with non-coplanar triangular faces. *)
VerificationTest[
	PrismMesh[
		{{1,0,1},{0,0,0},{2,0,0},{1,2,1},{0,2,0},{2,2,0.1}},
		{2,1}
	]["Coordinates"]//Sort,
	{{0,0,-(1/52)},{0,2,1/53},{1/2,0,10/21},{1/2,2,11/21},{1,0,0},{1,2,1/22},{1,0,1/3},
	{1,2,3/8},{1,0,44/45},{1,2,81/80},{3/2,2,6/11},{3/2,0,13/25},{2,2,1/14},{2,0,1/31}},
	{PrismMesh::alignerr},
	SameTest->(Norm[Flatten[#1-#2]]<10^-1&),
	TestID->"PrismMesh_non-coplanar-faces"
];


(* ::Subsubsection::Closed:: *)
(*CylinderMesh*)


VerificationTest[
	CylinderMesh[{2,2}]["Bounds"],
	{{-1.,1.},{-1.,1.},{-1.,1.}},
	TestID->"CylinderMesh_unit-cylinder"
];


VerificationTest[
	CylinderMesh[{{0,0,0},{1,1,1}},1/2,{4,4}]["Bounds"],
	{{-0.408248,1.40825},{-0.40474,1.40474},{-0.40474,1.40474}},
	SameTest->(Norm[#1-#2]<10^-3&),
	TestID->"CylinderMesh_arbitrary-cylinder"
];


(* ::Subsubsection::Closed:: *)
(*SphereMesh*)


VerificationTest[
	SphereMesh[2]["Bounds"],
	{{-1.,1.},{-1.,1.},{-1.,1.}},
	TestID->"SphereMesh_unit-sphere"
];


VerificationTest[
	SphereMesh[{1,2,3},3,3]["Bounds"],
	{{-1.80534,3.80534},{-0.805339,4.80534},{0.194661,5.80534}},
	SameTest->(Norm[#1-#2]<10^-3&),
	TestID->"SphereMesh_arbitrary-sphere"
];


VerificationTest[
	SphereMesh[2,"MeshOrder"->2]["MeshOrder"],
	2,
	TestID->"SphereMesh_order=2"
];


VerificationTest[
	SphereMesh[1],
	$Failed,
	{SphereMesh::noelems},
	TestID->"SphereMesh_too-few-elements"
];


(* ::Subsubsection::Closed:: *)
(*SphericalShellMesh*)


(* Test default SphericalShell with default "MeshOrder" *)
VerificationTest[
	SphericalShellMesh[{4,2}],
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"SphericalShellMesh_unit-shell"
];


(* Test default SphericalShell with "MeshOrder"->2 *)
VerificationTest[
	SphericalShellMesh[{2,1},"MeshOrder"->2],
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"SphericalShellMesh_unit-shell-order=2"
];


(* Test SphericalShell with arbitrary position and size. *)
VerificationTest[
	SphericalShellMesh[{1,2,3},{2,3},{4,2}],
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"SphericalShellMesh_arbitrary-shell"
];


(* ::Subsubsection::Closed:: *)
(*BallMesh*)


VerificationTest[
	BallMesh[2]["Bounds"],
	{{-1.,1.},{-1.,1.},{-1.,1.}},
	TestID->"BallMesh_unit-ball"
];


VerificationTest[
	BallMesh[{1,2,3},3,3]["Bounds"],
	{{-1.80534,3.80534},{-0.805339,4.80534},{0.194661,5.80534}},
	SameTest->(Norm[#1-#2]<10^-3&),
	TestID->"BallMesh_arbitrary-ball"
];


(* ::Subsection::Closed:: *)
(*EndTestSection*)


EndTestSection[];
