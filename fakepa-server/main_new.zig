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
    email: []const u8,
    dob: []const u8,
    age: u8,
    gender: []const u8,
    height: f32,
    weight: f32,
    habits: []const u8,
    medicalHistory: []const u8,
    allergies: []const u8,
};

const user_login = struct {
    email: []const u8,
    password: []const u8,
};

const Lookup = struct {
    pub fn get(val: []const u8) []const u8 {
        var conn = pool.acquire() catch |err| {
            std.debug.print("error in getting new conn: {any}", .{err});
            std.process.exit(1);
        };
        defer conn.release();

        var row = (conn.row(
            \\ SELECT uuid
            \\ FROM public.tokens
            \\ WHERE token = $1;
        , .{
            val,
        }) catch |err| {
            std.debug.print("pg error in checking auth: {any}", .{err});
            std.process.exit(1);
        });
        defer row.deinit() catch {};

        const name = row.get([]const u8, 0);
        // std.debug.print("logged in: {s}\n", .{name});
        return name;
    }
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
    pool = pg.Pool.init(stdalloc, .{ .size = 80, .connect = .{
        .port = 5432,
        .host = "127.0.0.1",
    }, .auth = .{
        .username = "postgres",
        .database = "fakepapq",
        .timeout = 2_592_000,
    } }) catch |err| {
        std.debug.print("pg error {any}", .{err});
        std.process.exit(1);
    };
    defer pool.deinit();

    {
        // var conn = pool.acquire() catch |err| {
        //     std.debug.print("error in getting new conn: {any}", .{err});
        //     std.process.exit(1);
        // };
        // defer conn.release();

        // var row = (conn.row(
        // _ = (conn.exec(
        _ = pool.exec(
            \\ CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
        , .{}) catch |err| {
            std.debug.print("query error added extension {any}", .{err});
            std.process.exit(1);
        };
        // defer row.deinit() catch {};
    }

    // _ = pool.exec

    {
        var conn = pool.acquire() catch |err| {
            std.debug.print("error in getting new conn: {any}", .{err});
            std.process.exit(1);
        };
        defer conn.release();

        var row = (conn.row(
            \\ CREATE TABLE IF NOT EXISTS public.patients (
            \\     medical_record_no UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            \\     name              TEXT NOT NULL,
            \\     email             TEXT NOT NULL UNIQUE,
            \\     date_of_birth     DATE NOT NULL,
            \\     age               SMALLINT NOT NULL,
            \\     gender            TEXT NOT NULL,
            \\     weight            REAL NOT NULL,
            \\     height            REAL NOT NULL,
            \\     habits            TEXT,
            \\     medical_history   TEXT,
            \\     allergies         TEXT,
            \\     password          TEXT NOT NULL
            \\ );
        , .{}) catch |err| {
            std.debug.print("query error creating table {any}", .{err});
            std.process.exit(1);
        }) orelse unreachable;
        defer row.deinit() catch {};
    }

    {
        var conn = pool.acquire() catch |err| {
            std.debug.print("error in getting new conn: {any}\n", .{err});
            std.process.exit(1);
        };
        defer conn.release();

        // Drop the existing table if it exists
        var drop_row = (conn.row(
            \\ DROP TABLE IF EXISTS public.tokens;
        , .{}) catch |err| {
            std.debug.print("query error dropping table: {any}\n", .{err});
            std.process.exit(1);
        }) orelse unreachable;
        defer drop_row.deinit() catch {};

        // Create the new table
        var create_row = (conn.row(
            \\ CREATE TABLE public.tokens (
            \\     uuid UUID PRIMARY KEY,
            \\     token TEXT NOT NULL
            \\ );
        , .{}) catch |err| {
            std.debug.print("query error creating table: {any}\n", .{err});
            std.process.exit(1);
        }) orelse unreachable;
        defer create_row.deinit() catch {};
    }

    // var result = pool.query("select 4", .{}) catch |err| {
    //     std.debug.print("query error {any}", .{err});
    //     std.process.exit(1);
    // };
    // defer result.deinit();
    //
    // while (try result.next()) |row| {
    //     std.debug.print("{any}\n", .{row.get(i32, 0)});
    //     // this is only valid until the next call to next(), deinit() or drain()
    // }

    // if (zap.Auth.BearerSingle. |auth|

    const files: []tn = try a.alloc(stdalloc, tn, 200);
    defer a.free(stdalloc, files);

    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = on_request,
        .log = true,
        .max_clients = 100000,
    });
    // zap.enableDebugLog();
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    zap.start(.{
        .threads = 2,
        .workers = 1, // 1 worker enables sharing state between threads
    });
}

fn pgPrintQuery(q: []const u8) void {
    var result = pool.query(q, .{}) catch |err| {
        std.debug.print("query error {any}", .{err});
        std.process.exit(1);
    };
    defer result.deinit();

    while (result.next() catch |err| {
        std.debug.print("error: {any}\n", .{err});
        return;
    }) |row| {
        std.debug.print("{any}\n", .{row});
        // for (row.column_name) |val| {
        //     std.debug.print("{s} ", val);
        //     // std.debug.print("{s}\n", .{row.get([]const u8, i)});
        // }
        // std.debug.print("\n", .{});
    }
}

fn on_request(r: zap.Request) void {
    if (r.query) |the_query| {
        std.debug.print("QUERY: {s}\n", .{the_query});
        return;
    }
    // var auth: ?[]const u8 = null;
    // if (r.getCookieStr(stdalloc, "auth")) |cookie| {
    //     auth = cookie;
    // }

    // if (r.body) |the_body| {
    //     std.debug.print("BODY: {s}\n", .{the_body});
    //     if (std.json.parseFromSlice(
    //         chat_mssg,
    //         std.heap.page_allocator,
    //         the_body,
    //         .{},
    //     )) |parsed| {
    //         std.debug.print("message: {s}\n", .{parsed.value.content});
    //         return;
    //     } else |err| {
    //         std.debug.print("no message :( {any}\n", .{err});
    //     }
    // }
    if (r.path) |the_path| {
        std.debug.print("PATH: {s}\n", .{the_path});
        // if (std.mem.eql(u8, the_path, "/")) {
        //     // r.sendFile("chatbot.html") catch |err| std.log.err()
        //     if (r.sendFile("web/doc.html")) {
        //         return;
        //     } else |err| {
        //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
        //         std.process.exit(1);
        //     }
        // } else if (std.mem.eql(u8, the_path, "api/addUser")) {
        if (std.mem.eql(u8, the_path, "/api/addUser")) {
            if (r.body) |the_body| {
                std.debug.print("BODY: {s}\n", .{the_body});
                if (std.json.parseFromSlice(
                    new_user,
                    std.heap.page_allocator,
                    the_body,
                    .{},
                )) |parsed| {
                    const val = parsed.value;
                    // pgPrintQuery("SELECT * FROM public.patients;");
                    // const state = pool.query(
                    {
                        var conn = pool.acquire() catch |err| {
                            std.debug.print("error in getting new conn: {any}", .{err});
                            std.process.exit(1);
                        };
                        defer conn.release();

                        var row = (conn.row(
                            \\ INSERT INTO public.patients (
                            \\     medical_record_no,
                            \\     name,
                            \\     email,
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
                            \\     uuid_generate_v4(),
                            \\     $1,
                            \\     $11,
                            \\     CAST($3 as DATE),
                            \\     $4,
                            \\     $5,
                            \\     $7,
                            \\     $6,
                            \\     $8, 
                            \\     $9,  
                            \\     $10,  
                            \\     $2 
                            \\ )
                            \\ ON CONFLICT (email) DO NOTHING;
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
                            val.email,
                        }) catch |err| {
                            std.debug.print("query error when adding user {any}", .{err});
                            std.process.exit(1);
                        }) orelse unreachable;
                        defer row.deinit() catch {};
                    }

                    std.debug.print("added user : <{s}>\n", .{parsed.value.name});
                    // if (try state) {
                    // } else {
                    //     std.debug.print("couldn't add user");
                    // }
                } else |err| {
                    std.debug.print("could not parse user :( {any}\n", .{err});
                }
                // pgPrintQuery("SELECT * FROM public.patients;"); //catch |err| {
                //     std.debug.print("error printing users table {any}", .{err});
                // };
                return;
            } else {
                std.debug.print("could not parse body to string", .{});
            }
            if (r.sendBody("user added")) {
                // std.debug.print("added user\n", .{});
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/api/auth")) {
            if (r.body) |the_body| {
                std.debug.print("BODY: {s}\n", .{the_body});
                if (std.json.parseFromSlice(
                    user_login,
                    std.heap.page_allocator,
                    the_body,
                    .{},
                )) |parsed| {
                    const val = parsed.value;
                    // pgPrintQuery("SELECT * FROM public.patients;");
                    // const state = pool.query(
                    {
                        var conn = pool.acquire() catch |err| {
                            std.debug.print("error in getting new conn: {any}", .{err});
                            std.process.exit(1);
                        };
                        defer conn.release();

                        var row = (conn.row(
                            \\ SELECT name
                            \\ FROM public.patients
                            \\ WHERE email = $1 AND password = $2;
                        , .{
                            val.email,
                            val.password,
                        }) catch |err| {
                            std.debug.print("pg error in checking auth: {any}", .{err});
                            std.process.exit(1);
                        }) orelse unreachable;
                        defer row.deinit() catch {};

                        const name = row.get([]const u8, 0);
                        std.debug.print("logged in: {s}\n", .{name});
                    }
                    // _ = pool.query(
                    //     \\
                    // , .{
                    //     val.email,
                    //     val.password,
                    // }) catch |err| {
                    //     std.debug.print("query error when adding user {any}", .{err});
                    //     std.process.exit(1);
                    // };
                    // if (try state) {
                    // } else {
                    //     std.debug.print("couldn't add user");
                    // }
                } else |err| {
                    std.debug.print("could not parse user :( {any}\n", .{err});
                }
                // pgPrintQuery("SELECT * FROM public.patients;"); //catch |err| {
                //     std.debug.print("error printing users table {any}", .{err});
                // };
                return;
            } else {
                std.debug.print("could not parse body to string", .{});
            }
            if (r.sendBody("")) {
                std.debug.print("added message\n", .{});
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/api/addMessage")) {
            if (r.sendBody("")) {
                std.debug.print("added message\n", .{});
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/")) {
            if (r.sendFile("swarup_pages/land.html")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/England.jpeg")) {
            if (r.sendFile("swarup_pages/England.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/arabia.jpeg")) {
            if (r.sendFile("swarup_pages/arabia.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/china.jpeg")) {
            if (r.sendFile("swarup_pages/china.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/france.jpeg")) {
            if (r.sendFile("swarup_pages/france.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/germany.jpeg")) {
            if (r.sendFile("swarup_pages/germany.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/india.jpeg")) {
            if (r.sendFile("swarup_pages/india.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/japan.jpeg")) {
            if (r.sendFile("swarup_pages/japan.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/spain.jpeg")) {
            if (r.sendFile("swarup_pages/spain.jpeg")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/login")) {
            if (r.sendFile("swarup_pages/login_page.html")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/sign_up")) {
            if (r.sendFile("swarup_pages/sign_up.html")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/chat")) {
            if (r.sendFile("swarup_pages/chatbot_new.html")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/terms")) {
            if (r.sendFile("swarup_pages/terms.html")) {
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/logo.png")) {
            if (r.sendFile("web/logo.png")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/favicon.ico")) {
            if (r.sendFile("web/logo.png")) {
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
            // } else if (std.mem.eql(u8, the_path, "/doctor_dashboard")) {
            //     if (r.sendFile("web/doctor_dashboard.html")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/doc")) {
            //     if (r.sendFile("web/index.html")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/terms")) {
            //     if (r.sendFile("web/terms.html")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/chatbot_interface")) {
            //     if (r.sendFile("web/chatbot_interface.html")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/login")) {
            //     if (r.sendFile("web/login_signup.html")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/kanishk-testing")) {
            //     if (r.sendFile("web/fakenlp.html")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/fakenlp.js")) {
            //     if (r.sendFile("web/fakenlp.js")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/vocab.txt")) {
            //     if (r.sendFile("web/vocab.txt")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/words.txt")) {
            //     if (r.sendFile("web/words.txt")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
            // } else if (std.mem.eql(u8, the_path, "/vectors.txt")) {
            //     if (r.sendFile("web/vectors.txt")) {
            //         return;
            //     } else |err| {
            //         std.log.err("oh nards, some error happened\n{any}\n", .{err});
            //         std.process.exit(1);
            //     }
        } else {
            if (r.sendFile("web/404.html")) {
                std.debug.print("404 who here?\n", .{});
                return;
            } else |err| {
                std.debug.print("could not serve req \n {any}\n", .{err});
                std.process.exit(1);
            }
        }
    }

    unreachable;
}
