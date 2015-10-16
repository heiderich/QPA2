BindGlobal( "FamilyOfQuiverRepresentationElements",
            NewFamily( "quiver representation elements" ) );
BindGlobal( "FamilyOfQuiverRepresentations",
            CollectionsFamily( FamilyOfQuiverRepresentationElements ) );

# TODO fix element stuff

DeclareRepresentation( "IsQuiverRepresentationElementRep", IsComponentObjectRep,
                       [ "representation", "vectors" ] );

InstallMethod( QuiverRepresentationElement, "for quiver representation and collection",
               [ IsQuiverRepresentation, IsDenseList ],
function( rep, vectors )
  local field, Q, numVertices, i, v;
  vectors := Immutable( vectors );
  field := FieldOfRepresentation( rep );
  Q := QuiverOfRepresentation( rep );
  numVertices := Length( Vertices( Q ) );
  if Length( vectors ) <> numVertices then
    Error( "Wrong number of vectors in QuiverRepresentationElement constructor ",
           "(", Length( vectors ), " given, expected ", numVertices, ")" );
  fi;
  for i in [ 1 .. numVertices ] do
    v := vectors[ i ];
    if not IsDenseList( v ) then
      Error( "Vector ", i, " in QuiverRepresentationElement constructor ",
             "is not a dense list: ", v );
    fi;
    if Length( v ) <> VertexDimension( rep, i ) then
      Error( "Vector ", i, " in QuiverRepresentationElement constructor ",
             "has wrong length (", Length( v ), ", should be ", VertexDimension( rep, i ), ")" );
    fi;
    if not ForAll( v, a -> a in field ) then
      Error( "Vector ", i, " in QuiverRepresentationElement constructor ",
             "contains elements which are not from the ground field" );
    fi;
  od;
  return QuiverRepresentationElementNC( rep, vectors );
end );

InstallMethod( QuiverRepresentationElementNC, "for quiver representation and collection",
               [ IsQuiverRepresentation, IsDenseList ],
function( rep, vectors )
  local elemType;
  elemType := NewType( FamilyOfQuiverRepresentationElements,
                       IsQuiverRepresentationElement and IsQuiverRepresentationElementRep );
  return Objectify( elemType,
                    rec( representation := rep,
                         vectors := vectors ) );
end );

InstallMethod( QuiverRepresentationElementByVertices, "for quiver representation and dense lists",
               [ IsQuiverRepresentation, IsDenseList, IsDenseList ],
function( R, vertices, vectors )
  local field, zero, dims, repVectors, numVectors, i, vertex, vertexNumber, vector;
  field := FieldOfRepresentation( R );
  zero := Zero( field );
  dims := DimensionVector( R );
  repVectors := List( dims,
                      d -> List( [ 1 .. d ], i -> zero ) );
  numVectors := Length( vectors );
  
  if Length( vertices ) <> numVectors then
    Error( "Different lengths of list of vertices (", Length( vertices ),
           ") and list of vectors (", numVectors, ")" );
  fi;
  for i in [ 1 .. numVectors ] do
    if not IsVertex( vertices[ i ] ) then
      Error( "Not a vertex: ", vertices[ i ] );
    fi;
    if not vertices[ i ] in QuiverOfRepresentation( R ) then
      Error( "Vertex ", vertices[ i ], " is not in the quiver of the representation ", R );
    fi;
    if ( not IsDenseList( vectors[ i ] ) ) or
       ( not ForAll( vectors[ i ], v -> v in field ) ) then
      Error( "Not a vector over the field ", field, ": ", vectors[ i ] );
    fi;
  od;
      
  for i in [ 1 .. numVectors ] do
    vertex := vertices[ i ];
    vertexNumber := VertexNumber( vertex );
    vector := vectors[ i ];
    if Length( vector ) <> dims[ vertexNumber ] then
      Error( "Wrong size of vector for vertex ", vertex,
             " (size is ", Length( vector ), ", should be ", dims[ vertexNumber ], ")" );
    fi;
    repVectors[ vertexNumber ] := vector;
  od;
  MakeImmutable( repVectors );
  return QuiverRepresentationElementNC( R, repVectors );
end );

InstallMethod( \in,
               [ IsQuiverRepresentationElement,
                 IsQuiverRepresentation ],
function( e, R )
  return RepresentationOfElement( e ) = R;
end );

InstallMethod( PrintObj, "for element of quiver representation",
               [ IsQuiverRepresentationElement ],
function( e )
  Print( "<quiver representation element ",
         ElementVectors( e ),
         ">" );
end );

InstallMethod( RepresentationOfElement, "for quiver representation element",
               [ IsQuiverRepresentationElement and IsQuiverRepresentationElementRep ],
function( e )
  return e!.representation;
end );

InstallMethod( ElementVectors, "for quiver representation element",
               [ IsQuiverRepresentationElement and IsQuiverRepresentationElementRep ],
function( e )
  return e!.vectors;
end );

InstallMethod( ElementVector, "for quiver representation element and positive integer",
               [ IsQuiverRepresentationElement, IsPosInt ],
function( e, i )
  return ElementVectors( e )[ i ];
end );

InstallMethod( ElementVector, "for quiver representation element and vertex",
               [ IsQuiverRepresentationElement, IsVertex ],
function( e, v )
  return ElementVectors( e )[ VertexNumber( v ) ];
end );

InstallMethod( PathAction,
               "for element of quiver representation and path",
               [ IsQuiverRepresentationElement, IsPath ],
function( e, p )
  local R, M, source_vec, target_vec, mult;
  R := RepresentationOfElement( e );
  M := MapForPath( R, p );
  source_vec := ElementVector( e, Source( p ) );
  target_vec := ImageElm( M, source_vec );
  return QuiverRepresentationElementByVertices( R, [ Target( p ) ], [ target_vec ] );
end );

InstallMethod( QuiverAlgebraAction,
               "for element of quiver representation and element of quiver algebra",
               [ IsQuiverRepresentationElement, IsQuiverAlgebraElement ],
function( re, ae )
  local Cs, Ps;
  Cs := Coefficients( ae );
  Ps := Paths( ae );
  return Sum( ListN( Cs, List( Ps, p -> PathAction( re, p ) ),
                     \* ) );
end );

InstallMethod( \=, "for elements of quiver representation",
               [ IsQuiverRepresentationElement, IsQuiverRepresentationElement ],
function( e1, e2 )
  return RepresentationOfElement( e1 ) = RepresentationOfElement( e2 )
         and ElementVectors( e1 ) = ElementVectors( e2 );
end );

InstallMethod( \+, "for elements of quiver representation",
               [ IsQuiverRepresentationElement, IsQuiverRepresentationElement ],
function( e1, e2 )
  return QuiverRepresentationElementNC( RepresentationOfElement( e1 ),
                                        ListN( ElementVectors( e1 ),
                                               ElementVectors( e2 ),
                                               \+ ) );
end );

InstallMethod( AdditiveInverse, "for element of quiver representation",
               [ IsQuiverRepresentationElement ],
function( e )
  return QuiverRepresentationElementNC
         ( RepresentationOfElement( e ),
           List( ElementVectors( e ), AdditiveInverse ) );
end );

InstallMethod( \*, "for multiplicative element and element of quiver representation",
               [ IsMultiplicativeElement, IsQuiverRepresentationElement ],
function( c, e )
  local R;
  R := RepresentationOfElement( e );
  if c in FieldOfRepresentation( R ) then
    return QuiverRepresentationElementNC( R,
                                          List( ElementVectors( e ), v -> c * v ) );
  else
    TryNextMethod();
  fi;
end );

InstallMethod( \*, "for element of quiver representation and multiplicative element",
               [ IsQuiverRepresentationElement, IsMultiplicativeElement ],
function( e, c )
  local R;
  R := RepresentationOfElement( e );
  if c in FieldOfRepresentation( R ) then
    return c * e;
  else
    TryNextMethod();
  fi;
end );

# TODO module structure


DeclareRepresentation( "IsQuiverRepresentationRep", IsComponentObjectRep and IsAttributeStoringRep,
                       [ "algebra", "dimensions", "matrices" ] );

InstallMethod( QuiverRepresentation, "for path algebra and dense lists",
               [ IsPathAlgebra, IsDenseList, IsDenseList ],
function( A, dimensions, matrices )
  return QuiverRepresentation( CategoryOfQuiverRepresentations( A ),
                               dimensions, matrices );
end );

InstallMethod( QuiverRepresentationNC, "for path algebra and dense lists",
               [ IsPathAlgebra, IsDenseList, IsDenseList ],
function( A, dimensions, matrices )
  return QuiverRepresentationNC( CategoryOfQuiverRepresentations( A ),
                                 dimensions, matrices );
  # local field, vecspace_type, make_vecspace, make_morphism;
  # field := LeftActingDomain( A );
  # vecspace_type := VectorSpaceTypeForRepresentations( A );
  # make_vecspace := dim -> MakeQPAVectorSpace( vecspace_type, field, dim );
  # make_morphism := mat -> MakeLinearTransformation( vecspace_type, field, mat );
  # return QuiverRepresentationByObjectsAndMorphismsNC
  #        ( A, List( dimensions, make_vecspace ), List( matrices, make_morphism ) );
end );

InstallMethod( QuiverRepresentation, "for representation category and dense lists",
               [ IsQuiverRepresentationCategory, IsDenseList, IsDenseList ],
function( cat, dimensions, matrices )
  local vecspace_cat;
  vecspace_cat := VectorSpaceCategory( cat );
  return QuiverRepresentationByObjectsAndMorphisms
         ( cat,
           List( dimensions, VectorSpaceConstructor( vecspace_cat ) ),
           List( matrices, LinearTransformationConstructor( vecspace_cat ) ) );
end );

InstallMethod( QuiverRepresentationNC, "for representation category and dense lists",
               [ IsQuiverRepresentationCategory, IsDenseList, IsDenseList ],
function( cat, dimensions, matrices )
  local vecspace_cat;
  vecspace_cat := VectorSpaceCategory( cat );
  return QuiverRepresentationByObjectsAndMorphismsNC
         ( cat,
           List( dimensions, VectorSpaceConstructor( vecspace_cat ) ),
           List( matrices, LinearTransformationConstructor( vecspace_cat ) ) );
end );

InstallMethod( QuiverRepresentationByObjectsAndMorphisms,
               [ IsQuiverRepresentationCategory, IsDenseList, IsDenseList ],
function( cat, objects, morphisms )
  local vecspace_cat, A, Q, vertices, numVertices, arrows, numArrows, i,
        src, correct_src, rng, correct_rng;

  A := AlgebraOfCategory( cat );
  Q := QuiverOfAlgebra( A );
  vertices := Vertices( Q );
  numVertices := Length( vertices );
  arrows := Arrows( Q );
  numArrows := Length( arrows );
  vecspace_cat := VectorSpaceCategory( cat );

  if Length( objects ) <> numVertices then
    Error( "Wrong number of objects ",
           "(", Length( objects ), " given, expected ", numVertices, ")" );
  fi;
  for i in [ 1 .. numVertices ] do
    if not ( IsCapCategoryObject( objects[ i ] )
             and CapCategory( objects[ i ] ) = vecspace_cat ) then
      Error( "Object ", objects[ i ], " for vertex ", vertices[ i ],
             " is not a CAP object in the correct category" );
    fi;
  od;
  if Length( morphisms ) <> numArrows then
    Error( "Wrong number of morphisms in QuiverRepresentation constructor ",
           "(", Length( morphisms ), " given, expected ", numArrows, ")" );
  fi;
  for i in [ 1 .. numArrows ] do
    if not ( IsCapCategoryMorphism( morphisms[ i ] ) and
             CapCategory( morphisms[ i ] ) = vecspace_cat ) then
      Error( "Morphism ", morphisms[ i ], " for arrow ", arrows[ i ],
             " is not a CAP object in the correct category" );
    fi;
    src := Source( morphisms[ i ] );
    correct_src := objects[ VertexNumber( Source( arrows[ i ] ) ) ];
    rng := Range( morphisms[ i ] );
    correct_rng := objects[ VertexNumber( Target( arrows[ i ] ) ) ];
    if not IsEqualForObjects( src, correct_src ) then
      Error( "Morphism ", morphisms[ i ], " for arrow ", arrows[ i ],
             " has wrong source (is ", src, ", should be ", correct_src, ")" );
    fi;
    if not IsEqualForObjects( rng, correct_rng ) then
      Error( "Morphism ", morphisms[ i ], " for arrow ", arrows[ i ],
             " has wrong source (is ", rng, ", should be ", correct_rng, ")" );
    fi;
  od;
  return QuiverRepresentationByObjectsAndMorphismsNC( cat, objects, morphisms );
end );

InstallMethod( QuiverRepresentationByObjectsAndMorphismsNC,
               [ IsQuiverRepresentationCategory, IsDenseList, IsDenseList ],
function( cat, objects, morphisms )
  local A, repType, R;
  A := AlgebraOfCategory( cat );
  repType := NewType( FamilyOfQuiverRepresentations,
                      IsQuiverRepresentation and IsQuiverRepresentationRep );
  R := rec();
  ObjectifyWithAttributes
    ( R, repType,
      AlgebraOfRepresentation, A,
      VectorSpacesOfRepresentation, objects,
      MapsOfRepresentation, morphisms,
      MatricesOfRepresentation, List( morphisms, MatrixOfLinearTransformation ),
      DimensionVector, List( objects, Dimension ) );
  Add( cat, R );
  return R;
end );

InstallMethod( UnderlyingCategoryForRepresentations, [ IsQuiverAlgebra ],
function( A )
  if IsLeftQuiver( QuiverOfAlgebra( A ) ) then
    return CategoryOfColSpaces( LeftActingDomain( A ) );
  else
    return CategoryOfRowSpaces( LeftActingDomain( A ) );
  fi;
end );

InstallMethod( VectorSpaceTypeForRepresentations, [ IsQuiverAlgebra ],
function( A )
  if IsLeftQuiver( QuiverOfAlgebra( A ) ) then
    return "col";
  else
    return "row";
  fi;
end );

InstallMethod( AsRepresentationOfQuotientAlgebra,
               "for quiver representation and quotient of path algebra",
               [ IsQuiverRepresentation, IsQuotientOfPathAlgebra ],
function( R, A )
  local kQ, rels, rel;
  kQ := PathAlgebra( A );
  rels := RelationsOfAlgebra( A );
  for rel in rels do
    if not IsZero( MapForAlgebraElement( R, rel ) ) then
      Error( "Not a well-defined representation of the algebra ", A,
             "; does not respect the relation ", rel );
    fi;
  od;
  return QuiverRepresentationNC( A, DimensionVector( R ),
                                 MatricesOfRepresentation( R ) );
end );

InstallMethod( QuiverRepresentation, "for quotient of path algebra and dense lists",
               [ IsQuotientOfPathAlgebra, IsDenseList, IsDenseList ],
function( A, dimensions, matrices )
  local kQ, rels, kQrep, rel;
  kQ := PathAlgebra( A );
  rels := RelationsOfAlgebra( A );
  kQrep := QuiverRepresentation( kQ, dimensions, matrices );
  return AsRepresentationOfQuotientAlgebra( kQrep, A );
end );

InstallMethod( QuiverRepresentationByArrows, "for quiver algebra and dense lists",
               [ IsQuiverAlgebra, IsDenseList, IsDenseList, IsDenseList ],
function( A, dimensions, arrows, matrices )
  return QuiverRepresentationByArrows
         ( CategoryOfQuiverRepresentations( A ),
           dimensions, arrows, matrices );
end );

InstallMethod( QuiverRepresentationByArrows, "for quiver algebra and dense lists",
               [ IsQuiverRepresentationCategory, IsDenseList, IsDenseList, IsDenseList ],
function( cat, dimensions, arrows, matrices )
  local A, field, Q, all_arrows, all_matrices, num_specified_arrows, i;
  A := AlgebraOfCategory( cat );
  field := LeftActingDomain( A );
  Q := QuiverOfAlgebra( A );
  all_arrows := Arrows( Q );
  all_matrices :=
    List( all_arrows,
          a ->
          MakeZeroMatrix( dimensions[ VertexNumber( LeftEnd( a ) ) ],
                          dimensions[ VertexNumber( RightEnd( a ) ) ],
                          field ) );
  num_specified_arrows := Length( arrows );
  if num_specified_arrows <> Length( matrices ) then
    Error( "Length of arrow list not the same as length of matrix list" );
  fi;
  for i in [ 1 .. num_specified_arrows ] do
    if DimensionsMat( matrices[ i ] ) <>
       DimensionsMat( all_matrices[ ArrowNumber( arrows[ i ] ) ] ) then
      Error( "Wrong dimensions of matrix for arrow ", arrows[ i ],
             " (dimensions are ", DimensionsMat( matrices[ i ] ),
             ", should be ",
             DimensionsMat( all_matrices[ ArrowNumber( arrows[ i ] ) ] ),
             ")" );
    fi;
    all_matrices[ ArrowNumber( arrows[ i ] ) ] := matrices[ i ];
  od;
  if IsPathAlgebra( A ) then
    return QuiverRepresentationNC( cat, dimensions, all_matrices );
  else
    return QuiverRepresentation( cat, dimensions, all_matrices );
  fi;
end );

InstallMethod( ZeroRepresentation, "for quiver algebra",
               [ IsQuiverAlgebra ],
function( A )
  local numVertices, field;
  numVertices := NumberOfVertices( QuiverOfAlgebra( A ) );
  field := LeftActingDomain( A );
  return QuiverRepresentationByArrows( A,
                                       List( [ 1 .. numVertices ],
                                             i -> Zero( field ) ),
                                       [], [] );
end );

InstallMethod( \=, [ IsQuiverRepresentation, IsQuiverRepresentation ],
function( R1, R2 )
  return AlgebraOfRepresentation( R1 ) = AlgebraOfRepresentation( R2 ) and
         DimensionVector( R1 ) = DimensionVector( R2 ) and
         MatricesOfRepresentation( R1 ) = MatricesOfRepresentation( R2 );
end );

InstallMethod( PrintObj, "for quiver representation",
               [ IsQuiverRepresentation ],
function( R )
  Print( "<quiver representation with dimensions ",
         DimensionVector( R ),
         " over ",
         AlgebraOfRepresentation( R ),
         ">" );
end );

InstallMethod( String, "for quiver representation",
               [ IsQuiverRepresentation ],
function( R )
  return JoinStringsWithSeparator( DimensionVector( R ),
                                   "," );
end );

InstallMethod( ViewObj, "for quiver representation",
               [ IsQuiverRepresentation ],
function( R )
  Print( "<", String( R ), ">" );
end );

InstallMethod( Zero, "for quiver representation",
               [ IsQuiverRepresentation ],
function( R )
  return QuiverRepresentationElementByVertices( R, [], [] );
end );

InstallMethod( VectorSpaceOfRepresentation, "for quiver representation and positive integer",
               [ IsQuiverRepresentation, IsPosInt ],
function( R, i )
  return VectorSpacesOfRepresentation( R )[ i ];
end );

InstallMethod( VertexDimension, "for quiver representation and positive integer",
               [ IsQuiverRepresentation, IsPosInt ],
function( R, i )
  return DimensionVector( R )[ i ];
end );

InstallMethod( VertexDimension, "for quiver representation and vertex",
               [ IsQuiverRepresentation, IsVertex ],
function( R, v )
  return VertexDimension( R, VertexNumber( v ) );
end );

InstallMethod( MapForArrow, "for quiver representation and positive integer",
               [ IsQuiverRepresentation, IsPosInt ],
function( R, i )
  return MapsOfRepresentation( R )[ i ];
end );

InstallMethod( MapForArrow, "for quiver representation and arrow",
               [ IsQuiverRepresentation, IsArrow ],
function( R, a )
  return MapForArrow( R, ArrowNumber( a ) );
end );

InstallMethod( MapForPath, "for quiver representation and vertex",
               [ IsQuiverRepresentation, IsVertex ],
function( R, v )
  return IdentityMat( VertexDimension( R, v ),
                      FieldOfRepresentation( R ) );
end );

InstallMethod( MapForPath, "for quiver representation and arrow",
               [ IsQuiverRepresentation, IsArrow ],
               MapForArrow );

InstallMethod( MapForPath, "for quiver representation and composite path",
               [ IsQuiverRepresentation, IsCompositePath ],
function( R, p )
  return PreCompose( List( ArrowListLR( p ), a -> MapForArrow( R, a ) ) );
end );

InstallMethod( MapForAlgebraElement, "for quiver representation and uniform quiver algebra element",
               [ IsQuiverRepresentation, IsQuiverAlgebraElement ],
function( R, e )
  return Sum( ListN( Coefficients( e ),
                     List( Paths( e ), p -> MapForPath( R, p ) ),
                     \* ) );
end );

InstallMethod( QuiverOfRepresentation, "for quiver representation",
               [ IsQuiverRepresentation ],
function( R )
  return QuiverOfAlgebra( AlgebraOfRepresentation( R ) );
end );

InstallMethod( FieldOfRepresentation, "for quiver representation",
               [ IsQuiverRepresentation ],
function( R )
  return LeftActingDomain( AlgebraOfRepresentation( R ) );
end );

InstallMethod( LeftActingDomain, "for quiver representation",
               [ IsQuiverRepresentation ],
               FieldOfRepresentation );

BindGlobal( "FamilyOfQuiverRepresentationBases",
            NewFamily( "quiver representation bases" ) );

DeclareRepresentation( "IsQuiverRepresentationBasisRep", IsComponentObjectRep,
                       [ "representation", "basisVectors" ] );

InstallMethod( CanonicalBasis, "for quiver representation",
               [ IsQuiverRepresentation ],
function( R )
  local Q, field, basis, vertices, dims, i, vertexBasis, j;
  Q := QuiverOfRepresentation( R );
  field := FieldOfRepresentation( R );
  basis := [];
  vertices := Vertices( Q );
  dims := DimensionVector( R );
  for i in [ 1 .. Length( vertices ) ] do
    vertexBasis := BasisVectors( CanonicalBasis( field ^ dims[ i ] ) );
    for j in [ 1 .. dims[ i ] ] do
      Add( basis,
           QuiverRepresentationElementByVertices
           ( R, [ vertices[ i ] ], [ vertexBasis[ j ] ] ) );
    od;
  od;
  return Objectify( NewType( FamilyOfQuiverRepresentationBases,
                             IsBasis and IsQuiverRepresentationBasisRep ),
                    rec( representation := R,
                         basisVectors := basis ) );
end );

InstallMethod( Basis, "for quiver representation",
               [ IsQuiverRepresentation ],
               CanonicalBasis );

InstallMethod( BasisVectors, "for quiver representation basis",
               [ IsBasis and IsQuiverRepresentationBasisRep ],
function( B )
  return B!.basisVectors;
end );

InstallMethod( UnderlyingLeftModule, "for quiver representation basis",
               [ IsBasis and IsQuiverRepresentationBasisRep ],
function( B )
  return B!.representation;
end );

InstallMethod( Coefficients, "for quiver representation basis and quiver representation element",
               [ IsBasis and IsQuiverRepresentationBasisRep,
                 IsQuiverRepresentationElement ],
function( B, e )
  return Concatenation( ElementVectors( e ) );
end );

BindGlobal( "FamilyOfQuiverRepresentationHomomorphisms",
            NewFamily( "quiver representation homomorphisms" ) );

# We need this because the builtin global function Image uses
# the FamilySource attribute to check whether a given map can
# be applied to a given element.
SetFamilySource( FamilyOfQuiverRepresentationHomomorphisms,
                 FamilyOfQuiverRepresentationElements );

DeclareRepresentation( "IsQuiverRepresentationHomomorphismRep",
                       IsComponentObjectRep and IsAttributeStoringRep,
                       [ ] );

InstallMethod( QuiverRepresentationHomomorphism,
               "for quiver representations and dense list",
               [ IsQuiverRepresentation, IsQuiverRepresentation,
                 IsDenseList ],
function( source, range, matrices )
  local vecspace_cat;
  vecspace_cat := VectorSpaceCategory( CapCategory( source ) );
  return QuiverRepresentationHomomorphismByMorphisms
         ( source, range,
           List( matrices, LinearTransformationConstructor( vecspace_cat ) ) );
end );

InstallMethod( QuiverRepresentationHomomorphismNC,
               "for quiver representations and dense list",
               [ IsQuiverRepresentation, IsQuiverRepresentation,
                 IsDenseList ],
function( source, range, matrices )
  local vecspace_cat;
  vecspace_cat := VectorSpaceCategory( CapCategory( source ) );
  return QuiverRepresentationHomomorphismByMorphismsNC
         ( source, range,
           List( matrices, LinearTransformationConstructor( vecspace_cat ) ) );
end );

InstallMethod( QuiverRepresentationHomomorphismByMorphisms,
               "for quiver representations and dense list",
               [ IsQuiverRepresentation, IsQuiverRepresentation,
                 IsDenseList ],
function( source, range, maps )
  local A, Q, i, src, correct_src, rng, correct_rng, arrow, comp1, comp2;
  A := AlgebraOfRepresentation( source );
  if A <> AlgebraOfRepresentation( range ) then
    Error( "Source and range are representations of different algebras" );
  fi;
  Q := QuiverOfAlgebra( A );
  for i in [ 1 .. NumberOfVertices( Q ) ] do
    src := Source( maps[ i ] );
    correct_src := VectorSpaceOfRepresentation( source, i );
    rng := Range( maps[ i ] );
    correct_rng := VectorSpaceOfRepresentation( range, i );
    if src <> correct_src then
      Error( "Map for vertex ", Vertex( Q, i ), " has wrong source",
             " (is ", src, ", should be ", correct_src, ")" );
    fi;
    if rng <> correct_rng then
      Error( "Map for vertex ", Vertex( Q, i ), " has wrong range",
             " (is ", rng, ", should be ", correct_rng, ")" );
    fi;
  od;
  for arrow in Arrows( Q ) do
    comp1 := PreCompose( MapForArrow( source, arrow ),
                         maps[ VertexNumber( Target( arrow ) ) ] );
    comp2 := PreCompose( maps[ VertexNumber( Source( arrow ) ) ],
                         MapForArrow( range, arrow ) );
    if comp1 <> comp2 then
      Error( "Does not commute with maps for arrow ", arrow );
    fi;
  od;
  return QuiverRepresentationHomomorphismByMorphismsNC( source, range, maps );
end );

InstallMethod( QuiverRepresentationHomomorphismByMorphismsNC,
               "for quiver representations and dense list",
               [ IsQuiverRepresentation, IsQuiverRepresentation,
                 IsDenseList ],
function( source, range, maps )
  local f;
  f := rec();
  ObjectifyWithAttributes
    ( f, NewType( FamilyOfQuiverRepresentationHomomorphisms,
                  IsQuiverRepresentationHomomorphism and
                  IsQuiverRepresentationHomomorphismRep ),
      Source, source,
      Range, range,
      MapsOfRepresentationHomomorphism, maps,
      MatricesOfRepresentationHomomorphism, List( maps, MatrixOfLinearTransformation ) );
  Add( CapCategory( source ), f );
  return f;
end );

InstallMethod( String,
               "for quiver representation homomorphism",
               [ IsQuiverRepresentationHomomorphism ],
function( f )
  return Concatenation( "(", String( Source( f ) ), ")",
                        "->",
                        "(", String( Range( f ) ), ")" );
end );

InstallMethod( ViewObj,
               "for quiver representation homomorphism",
               [ IsQuiverRepresentationHomomorphism ],
function( f )
  Print( "<", String( f ), ">" );
end );

InstallMethod( ImageElm,
               [ IsQuiverRepresentationHomomorphism,
                 IsQuiverRepresentationElement ],
function( f, e )
  return QuiverRepresentationElement
         ( Range( f ),
           ListN( MatricesOfRepresentationHomomorphism( f ),
                  ElementVectors( e ),
                  ImageElm ) );
end );



InstallMethod( CategoryOfQuiverRepresentations, "for quiver algebra",
               [ IsQuiverAlgebra ],
function( A )
  return CategoryOfQuiverRepresentationsOverVectorSpaceCategory
         ( A, UnderlyingCategoryForRepresentations( A ) );
end );

InstallMethod( CategoryOfQuiverRepresentationsOverVectorSpaceCategory,
               "for quiver algebra and vector space category",
               [ IsQuiverAlgebra, IsVectorSpaceCategory ],
function( A, vecspace_cat )
  local cat;

  cat := CreateCapCategory( Concatenation( "quiver representations over ", String( A ) ) );
  SetFilterObj( cat, IsQuiverRepresentationCategory );
  SetAlgebraOfCategory( cat, A );
  SetVectorSpaceCategory( cat, vecspace_cat );

  # TODO

  return cat;
end );

