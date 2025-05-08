// mixin 混入
function applyMixins(derivedCtor: any, constructors: any[]) {
  constructors.forEach((baseCtor) => {
    Object.getOwnPropertyNames(baseCtor.prototype).forEach((name) => {
      Object.defineProperty(
        derivedCtor.prototype,
        name,
        Object.getOwnPropertyDescriptor(baseCtor.prototype, name) ||
        Object.create(null)
      );
    });
  });
}

export { applyMixins };

class Aaa{
   aa(){}
}

class Bbb{
  bb(){}
}
class Ccc{


  cc(){}
}

interface Ccc extends Aaa,Bbb{}

applyMixins(Ccc,[Aaa,Bbb])

let  c = new Ccc()
c.aa()