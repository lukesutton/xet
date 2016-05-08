import Curassow
import Inquiline
import Nest

struct PublicContext: AppContext {
  typealias RequestContext = PublicRequestContext
  func requestContext(context: PublicContext, request: RequestType, params: [String: String]) -> RequestContext {
    return PublicRequestContext(request: request)
  }
}

struct PublicRequestContext {
  let request: RequestType
}

let userIndex = get("index") { (request: PublicRequestContext) in
  return Response(.Ok, contentType: "plain/text", content: "User index")
}

let userShow = get("show", "user") { (request: PublicRequestContext) in
  return Response(.Ok, contentType: "plain/text", content: "User show")
}

let routes = routeSet(userIndex, userShow)

let app = App<PublicContext>(context: PublicContext(), routes: routes)
