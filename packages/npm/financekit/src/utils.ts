import { Option as O, Predicate } from 'effect'

export type Primitive = string | number | boolean | undefined | null

export type Discriminated<
  Type,
  Field extends string & keyof Type,
  Value extends Primitive & Type[Field],
> = Type & { [field in Field]: Value }

export const discriminate =
  <
    Type,
    Field extends string & keyof Type,
    Value extends Primitive & Type[Field],
  >(
    discriminatorField: Field,
    discriminator: Value
  ) =>
  (a: Type): a is Discriminated<Type, Field, Value> => {
    return a[discriminatorField] === discriminator
  }

export const discriminateA =
  <
    Type,
    Field extends string & keyof Type,
    Value extends Primitive & Type[Field],
  >(
    discriminatorField: Field,
    discriminator: Value[]
  ) =>
  (a: Type): a is Discriminated<Type, Field, Value> => {
    return discriminator.includes(a[discriminatorField] as any)
  }

export const oLiftRefinement = <A, B extends A>(
  refinement: Predicate.Refinement<A, B>
): ((a: A) => O.Option<B>) => O.liftPredicate(refinement)
