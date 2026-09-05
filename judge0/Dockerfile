# Хост живёт на cgroup v2, а upstream-образ несёт isolate 1.8.1 (2021), который
# понимает только cgroup v1 и не запускает вообще ни одной посылки на таком
# хосте. isolate 2.0 умеет только cgroup v2, поэтому пересобираем его из
# исходников поверх штатного образа — судья остаётся оригинальный, обновляется
# только песочница.
FROM judge0/judge0:1.13.1

USER root

# gcc/make/git/libcap-dev уже есть в образе; buster в архиве, apt-get update
# лишний раз не трогаем.
RUN git clone --depth 1 --branch v2.0 https://github.com/ioi/isolate.git /tmp/isolate \
    && make -C /tmp/isolate isolate \
    && install -o root -g root -m 4755 /tmp/isolate/isolate /usr/local/bin/isolate \
    && rm -rf /tmp/isolate

COPY isolate-entrypoint.sh /usr/local/bin/isolate-entrypoint.sh
RUN chmod +x /usr/local/bin/isolate-entrypoint.sh

USER judge0

ENTRYPOINT ["/usr/local/bin/isolate-entrypoint.sh"]
