


InstallMethod( RestrictionFunctor, "for a homomorphism of quiver algebras",
        [ IsQuiverAlgebraHomomorphism, IsQuiverRepresentationCategory, IsQuiverRepresentationCategory ],
        function( f, C, D )
    
    local   restriction,  verteximages,  arrowimages,  A,  
            representation,  morphism;
    
    if AlgebraOfCategory( C ) <> Range( f ) then
        Error( "The entered category  C  does not coincide with the representation category",
               "of the range of the entered algebra homomorphism  f.\n" );
    fi;
    if AlgebraOfCategory( D ) <> Source( f ) then
        Error( "The entered category  D  does not coincide with the representation category",
               "of the source of the entered algebra homomorphism  f.\n" );
    fi;
    restriction := CapFunctor( "Restriction", C, D );
    
    verteximages := VertexImages( f );
    arrowimages := ArrowImages( f ); 
    A := Source( f );
    
    representation := function( R ) 
        local   arrows,  newspanningsetbyvertex,  inclusionsbyvertex,  
                projectionsbyvertex,  linear_transformations,  i,  
                source,  target,  lintrans,  rep;
         
        arrows := Arrows( QuiverOfAlgebra( A ) ); 
        newspanningsetbyvertex := List( verteximages, v -> List( Basis( R ), b -> AsVector ( QuiverAlgebraAction( b, v ) ) ) );
        inclusionsbyvertex := List( newspanningsetbyvertex, s -> SubspaceInclusion( AsQPAVectorSpace( R ), s ) ); 
        projectionsbyvertex := List( inclusionsbyvertex, LeftInverse );
        linear_transformations := [ ];
        for i in [ 1..Length( arrows ) ] do
            source := VertexNumber( Source( arrows[ i ] ) ); 
            target := VertexNumber( Target( arrows[ i ] ) );
            lintrans := PreCompose( [ inclusionsbyvertex[ source ], 
                                QuiverAlgebraActionAsLinearTransformation( R, arrowimages[ i ] ), projectionsbyvertex[ target ] ] ); 
            Add( linear_transformations, lintrans );
        od;
        rep := QuiverRepresentation( D, List( inclusionsbyvertex, Source ), linear_transformations );
        
        return [ rep, inclusionsbyvertex, projectionsbyvertex ];
    end;
    
    morphism := function( R1, h, R2 ) 
        local   rep1,  inc,  rep2,  proj,  hlintrans,  morphisms;
        
        rep1 := representation( Source( h ) );
        inc := rep1[ 2 ];
        rep2 := representation( Range( h ) );
        proj := rep2[ 3 ];
        hlintrans := AsLinearTransformation( h ); 
        morphisms := List( [ 1..Length( rep1[ 2 ] ) ], i -> PreCompose( [ inc[ i ], hlintrans, proj[ i ] ] ) ); 
                    
        return QuiverRepresentationHomomorphism( rep1[ 1 ], rep2[ 1 ], morphisms );
    end;
    
    AddObjectFunction( restriction, X -> representation( X )[ 1 ] ); 
    
    AddMorphismFunction( restriction, morphism );
    
    return restriction;
end 
  ); 

InstallMethod( RestrictionToLeftFunctor, "for a bimodule category",
        [ IsQuiverBimoduleCategory ],
        function( C )
    
    local   D,  f;
    
    D := UnderlyingRepresentationCategory( C );
    f := TensorAlgebraInclusions( AlgebraOfCategory( D ) )[ 1 ];
    return PreCompose( [ UnderlyingRepresentationFunctor( C ), 
                   RestrictionFunctor( f, D, CategoryOfQuiverRepresentations( Source( f ) ) ), 
                   AsLeftModuleFunctor( CategoryOfQuiverRepresentations( Source( f ) ) ) ] ); 
end );

InstallMethod( RestrictionToLeftFunctor, "for a left module category",
        [ IsLeftQuiverModuleCategory ],
        IdentityFunctor );

InstallMethod( RestrictionToLeftFunctor, "for a right module category",
        [ IsRightQuiverModuleCategory ],
        AsVectorSpaceFunctor );

InstallMethod( RestrictionToLeft, "for a module",
        [ IsQuiverModule ],
        function( M )
    
    return ApplyFunctor( RestrictionToLeftFunctor( CapCategory( M ) ), M );
end
  );

InstallMethod( RestrictionToLeft, "for a homomorphism",
        [ IsQuiverModuleHomomorphism ],
        function( f )
    
    return ApplyFunctor( RestrictionToLeftFunctor( CapCategory( f ) ), f );
end
  );


InstallMethod( RestrictionToRightFunctor, "for a bimodule category",
        [ IsQuiverBimoduleCategory ],
        function( C )
    
    local   D,  f;
    
    D := UnderlyingRepresentationCategory( C );
    f := TensorAlgebraInclusions( AlgebraOfCategory( D ) )[ 2 ];
    return PreCompose( [ UnderlyingRepresentationFunctor( C ), 
                   RestrictionFunctor( f, D, CategoryOfQuiverRepresentations( Source( f ) ) ), 
                   AsRightModuleFunctor( CategoryOfQuiverRepresentations( Source( f ) ) ) ] ); 
end );

InstallMethod( RestrictionToRightFunctor, "for a right module category",
        [ IsRightQuiverModuleCategory ],
        IdentityFunctor );

InstallMethod( RestrictionToRightFunctor, "for a left module category",
        [ IsLeftQuiverModuleCategory ],
        AsVectorSpaceFunctor );

InstallMethod( RestrictionToRight, "for a module",
        [ IsQuiverModule ],
        function( M )
    
    return ApplyFunctor( RestrictionToRightFunctor( CapCategory( M ) ), M );
end
  );

InstallMethod( RestrictionToRight, "for a homomorphism",
        [ IsQuiverModuleHomomorphism ],
        function( f )
    
    return ApplyFunctor( RestrictionToRightFunctor( CapCategory( f ) ), f );
end
  );

InstallMethod( LeftModuleToBimoduleFunctor, "for a module category",
        [ IsLeftQuiverModuleCategory ],
        function ( C )
    
    local   A,  K,  B,  f,  repC,  repB;
    
    repC := UnderlyingRepresentationCategory( C );
    A := AlgebraOfCategory( repC );
    K := FieldAsQuiverAlgebra( Direction( A ), LeftActingDomain( A ) );
    B := TensorProductOfAlgebras( A, K );
    f := TensorAlgebraRightIdentification( B );
    repB := CategoryOfQuiverRepresentations( B ); 
    
    return PreCompose( [ UnderlyingRepresentationFunctor( C ), RestrictionFunctor( f, repC, repB ), AsBimoduleFunctor( repB ) ] ); 
end );

InstallMethod( LeftModuleToBimodule, "for a module ",
        [ IsLeftQuiverModule ],
        function ( M )
    
    return ApplyFunctor( LeftModuleToBimoduleFunctor( CapCategory( M ) ), M );
end
  );

InstallMethod( RightModuleToBimoduleFunctor, "for a module category",
        [ IsRightQuiverModuleCategory ],
        function ( C )
    
    local   A,  K,  B,  f,  repC,  repB;
    
    repC := UnderlyingRepresentationCategory( C );
    A := AlgebraOfCategory( repC );
    K := FieldAsQuiverAlgebra( Direction( A ), LeftActingDomain( A ) );
    B := TensorProductOfAlgebras( K, A );
    f := TensorAlgebraLeftIdentification( B );
    repB := CategoryOfQuiverRepresentations( B ); 
    
    return PreCompose( [ UnderlyingRepresentationFunctor( C ), RestrictionFunctor( f, repC, repB ), AsBimoduleFunctor( repB ) ] ); 
end );

InstallMethod( RightModuleToBimodule, "for a module ",
        [ IsRightQuiverModule ],
        function ( M )
    
    return ApplyFunctor( RightModuleToBimoduleFunctor( CapCategory( M ) ), M );
end
  );

InstallMethod( AsVectorSpaceFunctor, "for a representation category", 
        [ IsQuiverRepresentationCategory ],
        function ( C )
    
    local F;
    
    F := CapFunctor( "AsVectorSpace", C, VectorSpaceCategory( C ) ); 
    
    AddObjectFunction( F, X -> DirectSum( VectorSpacesOfRepresentation( X ) ) );
    AddMorphismFunction( F, function( X, f, Y ) return DirectSumFunctorial( MapsOfRepresentationHomomorphism( f ) ); end );
    
    return F;
end
  );

InstallMethod( AsVectorSpaceFunctor, "for a representation category", 
        [ IsQuiverModuleCategory ],
        function ( C )
    
    return PreCompose( UnderlyingRepresentationFunctor( C ), AsVectorSpaceFunctor( UnderlyingRepresentationCategory( C ) ) );
end
  );