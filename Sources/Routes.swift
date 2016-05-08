import Nest
import Inquiline

protocol AppContext {
  associatedtype RequestContext
  func requestContext(appContext: Self, request: RequestType, params: [String: String]) -> RequestContext
}

struct App<Context: AppContext> {
  let context: Context
  let routeSets: [RouteSet<Context.RequestContext>]
  let routes: [Route<Context.RequestContext>]

  init(context: Context, routes routeSets: RouteSet<Context.RequestContext>...) {
    self.context = context
    self.routeSets = routeSets
    self.routes = routeSets.flatMap {$0.routes}
  }

  func handler(request: RequestType) -> ResponseType? {
    for route in routes {
      guard methodMatches(route, request) else { continue }
      guard let params = route.path.extract(request.path) else { continue }
      // Check each test. Bail on the first
      // create context. Run it through middleware.
      return route.handler(context.requestContext(context, request: request, params: params))
    }
    return nil
  }

  private func methodMatches(route: Route<Context.RequestContext>, _ request: RequestType) -> Bool {
    return route.methodStrings.contains(request.method.lowercaseString)
  }
}

func stack(handlers: (RequestType -> ResponseType?)...) -> (RequestType -> ResponseType) {
  return { request in
    for handler in handlers {
      if let response = handler(request) {
        return response
      }
    }

    return Response(.Ok, contentType: "plain/text", content: "Booo, missing")
  }
}

enum HTTPMethod: String {
  case GET = "GET"
  case POST = "POST"
  case PUT = "PUT"
  case PATCH = "PATCH"
  case HEAD = "HEAD"
  case OPTIONS = "OPTIONS"
}

enum FilterResponse<RequestContext> {
  case Next(RequestContext)
  case Respond(ResponseType)
}

struct Route<RequestContext> {
  let name: String
  let methods: Set<HTTPMethod>
  let path: Path
  let handler: RequestContext -> ResponseType
  let tests: [(RequestType -> Bool)]
  let beforeFilters: [(RequestContext -> FilterResponse<RequestContext>)]
  let afterFilters: [(ResponseType -> ResponseType)]

  func handle(context: RequestContext) -> ResponseType {
    return handler(context)
  }

  var methodStrings: Set<String> {
    return Set<String>(methods.map {$0.rawValue.lowercaseString})
  }
}

struct RouteSet<RequestContext> {
  let routes: [Route<RequestContext>]
  let tests: [(RequestType -> Bool)] = []
  let beforeFilters: [(RequestContext -> FilterResponse<RequestContext>)] = []
  let afterFilters: [(ResponseType -> ResponseType)] = []

  subscript(name: String) -> Route<RequestContext>? {
    return routes.filter {$0.name == name}[0]
  }
}

func routeSet<C>(routes: Route<C>...) -> RouteSet<C> {
  return RouteSet<C>(routes: routes)
}

func get<C>(name: String,
          _ path: Path = Path([]),
           tests: [(RequestType -> Bool)] = [],
          before: [(C) -> FilterResponse<C>] = [],
           after: [(ResponseType) -> ResponseType] = [],
         handler: C -> ResponseType) -> Route<C> {

  return Route(
    name: name,
    methods: Set<HTTPMethod>([.GET]),
    path: path,
    handler: handler,
    tests: tests,
    beforeFilters: before,
    afterFilters: after
  )
}
