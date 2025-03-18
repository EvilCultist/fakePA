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

const chat_mssg = struct {
    role: Role,
    content: []const u8,
};

const new_user = struct {
    name: []const u8,
    psswd: []const u8,
    dob: []const u8,
    age: u8,
    gender: []const u8,
    height: u8,
    weight: u8,
    habits: []const u8,
    medicalHistory: []const u8,
    allergies: []const u8,
};

const n_tokens = 0;

///json.static.Parsed(main.chat_mssg){
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
///     .value = main.chat_mssg{
///         .role = main.Role.user,
///         .content = { 110, 111 }
///     }
/// }

// fn query_exit(err: ) void{
//         std.debug.print("query error {any}", .{err});
//         std.process.exit(1);
// }

var pool: *pg.Pool = undefined;

pub fn main() !void {
    pool = pg.Pool.init(stdalloc, .{ .size = 2, .connect = .{
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
            chat_mssg,
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
            if (r.sendFile("web/doc.html")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "api/addUser")) {
            if (r.body) |the_body| {
                std.debug.print("BODY: {s}\n", .{the_body});
                if (std.json.parseFromSlice(
                    new_user,
                    std.heap.page_allocator,
                    the_body,
                    .{},
                )) |parsed| {
                    const val = parsed.value;
                    // const state = pool.query(
                    _ = pool.query(
                        \\ INSERT INTO public.patients (
                        \\     medical_record_no,
                        \\     name,
                        \\     date_of_birth,
                        \\     age,
                        \\     gender,
                        \\     weight,
                        \\     height,
                        \\     habits,
                        \\     medical_history,
                        \\     allergies,
                        \\     password
                        \\ )
                        \\ VALUES (
                        \\     uuid_generate_v4(),  -- Automatically generates a UUID
                        \\     $1  -- 'John Doe',          f the patient
                        \\     $2  -- '1990-05-15',        f birth
                        \\     $3  -- 35,                  f the patient
                        \\     $4  -- 'Male',              
                        \\     $5  -- 75.5,                 (in kilograms)
                        \\     $6  -- 175.0,                (in centimeters)
                        \\     $7  -- 'Non-smoker',        
                        \\     $8  -- 'No significant history',
                        \\     $9  -- 'Peanuts',        
                        \\     $10 -- 'hashed_password_123'  
                        \\ );
                    , .{
                        val.name,
                        val.psswd,
                        val.dob,
                        val.age,
                        val.gender,
                        val.height,
                        val.weight,
                        val.habits,
                        val.medicalHistory,
                        val.allergies,
                    }) catch |err| {
                        std.debug.print("query error {any}", .{err});
                        std.process.exit(1);
                    };

                    std.debug.print("added user : <{s}>\n", .{parsed.value.name});
                    // if (try state) {
                    // } else {
                    //     std.debug.print("couldn't add user");
                    // }
                } else |err| {
                    std.debug.print("could not parse user :( {any}\n", .{err});
                }
                return;
            }
            if (r.sendBody("user added")) {
                // std.debug.print("added user\n", .{});
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
        } else if (std.mem.eql(u8, the_path, "/doctor_dashboard")) {
            if (r.sendFile("web/doctor_dashboard.html")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/doc")) {
            if (r.sendFile("web/index.html")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/terms")) {
            if (r.sendFile("web/terms.html")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/logo.png")) {
            if (r.sendFile("web/logo.png")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/chatbot_interface")) {} else if (std.mem.eql(u8, the_path, "/chatbot_interface")) {
            if (r.sendFile("web/chatbot_interface.html")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/kanishk-testing")) {
            if (r.sendFile("web/fakenlp.html")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/fakenlp.js")) {
            if (r.sendFile("web/fakenlp.js")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/vocab.txt")) {
            if (r.sendFile("web/vocab.txt")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/words.txt")) {
            if (r.sendFile("web/words.txt")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/vectors.txt")) {
            if (r.sendFile("web/vectors.txt")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else {
            if (r.sendFile("web/404.html")) {
                std.debug.print("404 who here?\n", .{});
                return;
            } else |err| {
                std.debug.print("well see sometimes things happen\n {any}\n", .{err});
                std.process.exit(1);
            }
        }
    }

    unreachable;
}
