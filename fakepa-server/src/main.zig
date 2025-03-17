//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const zap = @import("zap");
const pg = @import("pg");
// const routes = @import("routes");

const a = std.mem.Allocator;
const stdalloc = std.heap.c_allocator;

const tn = struct {
    var name: u8[20] = "";
};

const Role = enum { user, admin, doctor };

const form_body = struct {
    role: Role,
    content: []const u8,
};

const n_tokens = 0;

///json.static.Parsed(main.form_body){
///     .arena = heap.arena_allocator.ArenaAllocator{
///         .child_allocator = mem.Allocator{
///             .ptr = anyopaque@0,
///             .vtable = mem.Allocator.VTable{ ... }
///         },
///         .state = heap.arena_allocator.ArenaAllocator.State{
///             .buffer_list = linked_list.SinglyLinkedList(usize){ ... },
///             .end_index = 0
///         }
///     },
///     .value = main.form_body{
///         .role = main.Role.user,
///         .content = { 110, 111 }
///     }
/// }

// fn query_exit(err: ) void{
//         std.debug.print("query error {any}", .{err});
//         std.process.exit(1);
// }

pub fn main() !void {
    var pool = pg.Pool.init(stdalloc, .{ .size = 20, .connect = .{
        .port = 5432,
        .host = "127.0.0.1",
    }, .auth = .{
        .username = "postgres",
        .database = "postgres",
        .timeout = 2_592_000,
    } }) catch |err| {
        std.debug.print("pg error {any}", .{err});
        std.process.exit(1);
    };
    defer pool.deinit();

    _ = pool.query("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";", .{}) catch |err| {
        std.debug.print("query error {any}", .{err});
        std.process.exit(1);
    };

    var result = pool.query("select 4", .{}) catch |err| {
        std.debug.print("query error {any}", .{err});
        std.process.exit(1);
    };
    defer result.deinit();

    while (try result.next()) |row| {
        std.debug.print("{any}\n", .{row.get(i32, 0)});
        // this is only valid until the next call to next(), deinit() or drain()
    }

    const files: []tn = try a.alloc(stdalloc, tn, 200);
    defer a.free(stdalloc, files);

    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = on_request,
        .log = true,
        .max_clients = 100000,
    });
    zap.enableDebugLog();
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    zap.start(.{
        .threads = 2,
        .workers = 1, // 1 worker enables sharing state between threads
    });
}

fn on_request(r: zap.Request) void {
    if (r.query) |the_query| {
        std.debug.print("QUERY: {s}\n", .{the_query});
        return;
    }
    if (r.body) |the_body| {
        std.debug.print("BODY: {s}\n", .{the_body});
        if (std.json.parseFromSlice(
            form_body,
            std.heap.page_allocator,
            the_body,
            .{},
        )) |parsed| {
            std.debug.print("message: {s}\n", .{parsed.value.content});
        } else |err| {
            std.debug.print("no message :( {any}\n", .{err});
        }
        return;
    }
    if (r.path) |the_path| {
        std.debug.print("PATH: {s}\n", .{the_path});
        if (std.mem.eql(u8, the_path, "/")) {
            // r.sendFile("chatbot.html") catch |err| std.log.err()
            if (r.sendFile("web/index.html")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "api/addUser")) {
            if (r.sendBody("")) {
                std.debug.print("added user\n", .{});
                return;
            } else |err| {
                std.debug.print("well see sometimes things happen\n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "api/addMessage")) {
            if (r.sendBody("")) {
                std.debug.print("added message\n", .{});
                return;
            } else |err| {
                std.debug.print("well see sometimes things happen\n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/kanishk-testing")) {
            if (r.sendFile("web/fakenlp.html")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/fakenlp.js")) {
            if (r.sendFile("web/fakenlp.js")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/vocab.txt")) {
            if (r.sendFile("web/vocab.txt")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/vectors.txt")) {
            if (r.sendFile("web/vectors.txt")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else {
            if (r.sendFile("web/404.html")) {
                std.debug.print("added user\n", .{});
                return;
            } else |err| {
                std.debug.print("well see sometimes things happen\n {any}\n", .{err});
                std.process.exit(1);
            }
        }
    }

    unreachable;
}
