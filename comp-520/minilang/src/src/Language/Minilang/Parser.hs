module Language.Minilang.Parser
( minilang
, Input
, stmt
, decl
, varDecl
, assignStmt
, whileStmt
, ifStmt
, printStmt
, readStmt
) where

import Language.Minilang.Lexer
import Language.Minilang.Parser.Expression ( expr )
import Language.Minilang.SrcAnn
import Language.Minilang.Syntax

import Text.Megaparsec

minilang :: Parser SrcAnnProgram
minilang = Program <$> many decl <*> many stmt

stmt :: Parser SrcAnnStatement
stmt
    = whileStmt
    <|> ifStmt
    <|> assignStmt
    <|> printStmt
    <|> readStmt

decl :: Parser SrcAnnDeclaration
decl
    = varDecl

varDecl :: Parser SrcAnnDeclaration
varDecl = withSrcAnnId $ do
    try $ tokVar
    ident <- withSrcAnnId identifier
    colon
    ty <- withSrcAnnId type_
    semicolon
    return $ Var ident ty
    
assignStmt :: Parser SrcAnnStatement
assignStmt = withSrcAnnFix $ do
    ident <- try $ withSrcAnnId identifier <* equals
    e <- expr
    semicolon
    return $ Assign ident e

whileStmt :: Parser SrcAnnStatement
whileStmt = withSrcAnnFix $ do
    try tokWhile
    e <- expr
    tokDo
    body <- many stmt
    tokDone
    return $ While e body

ifStmt :: Parser SrcAnnStatement
ifStmt = withSrcAnnFix $ do
    try tokIf
    e <- expr
    tokThen
    thenBody <- many stmt
    elseBody <- option [] $ try tokElse *> many stmt
    tokEnd
    return $ If e thenBody elseBody
        
printStmt :: Parser SrcAnnStatement
printStmt = withSrcAnnFix $ do
    try tokPrint
    e <- expr
    semicolon
    return $ Print e

readStmt :: Parser SrcAnnStatement
readStmt = withSrcAnnFix $ do
    try tokRead
    ident <- withSrcAnnId identifier
    semicolon
    return $ Read ident
