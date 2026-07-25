function bonsai-start
    cd ~/dev/bonsai-llama-cpp
    ./build/bin/llama-server -m Ternary-Bonsai-27B-Q2_0.gguf -c 262144 -ngl 99 -ctk q4_0 -ctv q4_0 --host 0.0.0.0 --port 8080 > server.log 2>&1 &
    disown
    echo "Bonsai arrancando en background — mira ~/dev/bonsai-llama-cpp/server.log"
end
