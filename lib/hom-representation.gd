DeclareCategory( "IsHomRepresentation", IsHomObject );

DeclareCategory( "IsQuiverRepresentationXHomomorphism",
                 IsMapping and IsSPGeneralMapping and IsVectorSpaceHomomorphism
                 and IsQuiverRepresentationElement );

DeclareOperation( "Hom", [ IsPosInt, IsQuiverRepresentation, IsQuiverRepresentation ] );

DeclareOperation( "Hom", [ IsPosInt, IsQuiverRepresentationHomomorphism, IsQuiverRepresentation ] );

DeclareOperation( "Hom", [ IsPosInt, IsQuiverRepresentation, IsQuiverRepresentationHomomorphism ] );

DeclareOperation( "Hom", [ IsPosInt, IsQuiverRepresentationHomomorphism, IsQuiverRepresentationHomomorphism ] );

DeclareOperation( "HomFunctor",
                  [ IsPosInt, IsQuiverRepresentationCategory, IsQuiverRepresentationCategory ] );

DeclareOperation( "HomFunctor", [ IsQuiverRepresentationCategory ] );


DeclareOperation( "PreComposeFunctors", [ IsCapFunctor, IsCapFunctor ] );
DeclareOperation( "PreComposeFunctors", [ IsDenseList, IsCapFunctor ] );
